package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.utils.ImageHelper;
import jakarta.annotation.PostConstruct;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

/**
 * Manages the on-disk image cache for article thumbnails.
 * <ul>
 *   <li>Downloads images on first access and serves subsequent requests from disk.</li>
 *   <li>Evicts oldest files (by last-modified time) when the total cache size exceeds the configured limit.</li>
 *   <li>Removes files older than {@code IMAGE_CACHE_MAX_AGE_DAYS} on a nightly schedule.</li>
 * </ul>
 * <p>
 * Cache layout is intentionally flat — one file per {@code itemId} directly under
 * {@link #cacheDir}. Accordingly the cleanup routines use {@link Files#list}
 * rather than {@link Files#walk}, which prevents descending into system
 * directories if the cache root is ever misconfigured (see the init-time
 * guards below).
 */
@Service
public class ImageCacheService {

    private static final Logger logger = LogManager.getLogger();

    private static final Set<Path> FORBIDDEN_ROOTS = Set.of(
            Paths.get("/"),
            Paths.get("/proc"),
            Paths.get("/sys"),
            Paths.get("/dev"),
            Paths.get("/etc"),
            Paths.get("/boot"));

    /** Directory used to store cached images. Defaults to a fixed path inside the system temp dir. */
    @Value("${IMAGE_CACHE_DIR:#{systemProperties['java.io.tmpdir']}/newsku-images}")
    private String cacheDirPath;

    /** Maximum total cache size in megabytes before LRU eviction kicks in. */
    @Value("${IMAGE_CACHE_MAX_SIZE_MB:500}")
    private long maxCacheSizeMb;

    /** Files not accessed within this many days are removed by the nightly cleanup. */
    @Value("${IMAGE_CACHE_MAX_AGE_DAYS:7}")
    private int maxAgeDays;

    private Path cacheDir;

    @PostConstruct
    public void init() throws IOException {
        String resolvedPath = cacheDirPath;
        if (resolvedPath == null || resolvedPath.isBlank()) {
            // Spring's @Value default only kicks in for unset properties, not for
            // blank ones. docker-compose passes IMAGE_CACHE_DIR="" when the host
            // variable is unset, which would otherwise resolve to the container's
            // working directory ("/") — catastrophic for the walk-based cleanup.
            resolvedPath = System.getProperty("java.io.tmpdir") + "/newsku-images";
            logger.info("IMAGE_CACHE_DIR was blank, falling back to {}", resolvedPath);
        }

        cacheDir = Paths.get(resolvedPath).toAbsolutePath().normalize();

        if (FORBIDDEN_ROOTS.contains(cacheDir)) {
            throw new IllegalStateException(
                    "Refusing to use " + cacheDir + " as image cache directory — set IMAGE_CACHE_DIR to a dedicated path");
        }

        Files.createDirectories(cacheDir);
        logger.info("Image cache initialised at {} (max {}MB, max age {} days)",
                cacheDir, maxCacheSizeMb, maxAgeDays);
    }

    /**
     * Returns the local {@link Path} for the cached image belonging to {@code itemId}.
     * Downloads the image from {@code imageUrl} if it is not yet cached.
     */
    public Path getCachedImage(String itemId, String imageUrl) throws IOException {
        Path filePath = cacheDir.resolve(itemId);
        if (!Files.exists(filePath)) {
            logger.info("Image not in cache for item {}, downloading from {}", itemId, imageUrl);
            ImageHelper.downloadImageToPath(imageUrl, filePath);
            evictIfNeeded();
        }
        return filePath;
    }

    /**
     * Evicts the oldest files until the total cache size is below 80 % of the configured limit.
     * Called after every cache-miss download to keep the cache within bounds.
     */
    private void evictIfNeeded() {
        long maxBytes = maxCacheSizeMb * 1024 * 1024;
        List<Path> files = listCacheFiles();
        if (files.isEmpty()) return;

        files.sort(Comparator.comparingLong(this::lastModifiedMillis));

        long totalSize = 0;
        for (Path file : files) {
            totalSize += fileSize(file);
        }

        if (totalSize <= maxBytes) {
            return;
        }

        logger.info("Cache size {}MB exceeds limit {}MB – evicting oldest files",
                totalSize / (1024 * 1024), maxCacheSizeMb);

        long targetSize = (long) (maxBytes * 0.8); // evict down to 80 % of the limit
        for (Path file : files) {
            if (totalSize <= targetSize) break;
            try {
                long fileSize = Files.size(file);
                Files.delete(file);
                totalSize -= fileSize;
                logger.debug("Evicted cached image: {}", file.getFileName());
            } catch (NoSuchFileException e) {
                // already gone — concurrent eviction or external cleanup
            } catch (IOException e) {
                logger.warn("Could not evict cached image {}: {}", file.getFileName(), e.getMessage());
            }
        }
    }

    /**
     * Nightly cleanup: removes all cached files that have not been modified within
     * {@code IMAGE_CACHE_MAX_AGE_DAYS} days.
     */
    @Scheduled(cron = "0 0 3 * * *")
    public void cleanupExpiredFiles() {
        logger.info("Running scheduled image cache cleanup (max age {} days)…", maxAgeDays);
        long cutoffMs = Instant.now().minus(maxAgeDays, ChronoUnit.DAYS).toEpochMilli();

        for (Path file : listCacheFiles()) {
            long modified = lastModifiedMillis(file);
            if (modified == Long.MAX_VALUE || modified >= cutoffMs) continue;
            try {
                Files.delete(file);
                logger.debug("Removed expired cached image: {}", file.getFileName());
            } catch (NoSuchFileException e) {
                // already gone
            } catch (IOException e) {
                logger.warn("Could not remove expired image {}: {}", file.getFileName(), e.getMessage());
            }
        }
    }

    /**
     * Returns every regular file directly inside {@link #cacheDir}. Intentionally
     * non-recursive — the cache layout is flat and recursing could wander into
     * bind-mounted system directories if the root is ever misconfigured.
     */
    private List<Path> listCacheFiles() {
        List<Path> files = new ArrayList<>();
        try (Stream<Path> stream = Files.list(cacheDir)) {
            stream.filter(Files::isRegularFile).forEach(files::add);
        } catch (NoSuchFileException e) {
            return List.of();
        } catch (IOException e) {
            logger.warn("Error listing image cache directory {}: {}", cacheDir, e.getMessage());
        }
        return files;
    }

    private long lastModifiedMillis(Path p) {
        try {
            return Files.getLastModifiedTime(p).toMillis();
        } catch (NoSuchFileException e) {
            return Long.MAX_VALUE;
        } catch (IOException e) {
            logger.debug("Cannot read mtime of {}: {}", p, e.getMessage());
            return Long.MAX_VALUE;
        }
    }

    private long fileSize(Path p) {
        try {
            return Files.size(p);
        } catch (NoSuchFileException e) {
            return 0L;
        } catch (IOException e) {
            logger.debug("Cannot read size of {}: {}", p, e.getMessage());
            return 0L;
        }
    }
}
