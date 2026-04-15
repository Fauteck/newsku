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
import java.nio.file.Path;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Manages the on-disk image cache for article thumbnails.
 * <ul>
 *   <li>Downloads images on first access and serves subsequent requests from disk.</li>
 *   <li>Evicts oldest files (by last-modified time) when the total cache size exceeds the configured limit.</li>
 *   <li>Removes files older than {@code IMAGE_CACHE_MAX_AGE_DAYS} on a nightly schedule.</li>
 * </ul>
 */
@Service
public class ImageCacheService {

    private static final Logger logger = LogManager.getLogger();

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
        cacheDir = Path.of(cacheDirPath);
        Files.createDirectories(cacheDir);
        logger.info("Image cache initialised at {} (max {}MB, max age {} days)",
                cacheDir.toAbsolutePath(), maxCacheSizeMb, maxAgeDays);
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
        try {
            List<Path> files = Files.walk(cacheDir)
                    .filter(Files::isRegularFile)
                    .sorted(Comparator.comparingLong(p -> {
                        try {
                            return Files.getLastModifiedTime(p).toMillis();
                        } catch (IOException e) {
                            return Long.MAX_VALUE;
                        }
                    }))
                    .collect(Collectors.toList());

            long totalSize = files.stream().mapToLong(p -> {
                try {
                    return Files.size(p);
                } catch (IOException e) {
                    return 0L;
                }
            }).sum();

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
                } catch (IOException e) {
                    logger.warn("Could not evict cached image {}: {}", file.getFileName(), e.getMessage());
                }
            }
        } catch (IOException e) {
            logger.warn("Error during cache eviction: {}", e.getMessage());
        }
    }

    /**
     * Nightly cleanup: removes all cached files that have not been modified within
     * {@code IMAGE_CACHE_MAX_AGE_DAYS} days.
     */
    @Scheduled(cron = "0 0 3 * * *")
    public void cleanupExpiredFiles() {
        logger.info("Running scheduled image cache cleanup (max age {} days)…", maxAgeDays);
        Instant cutoff = Instant.now().minus(maxAgeDays, ChronoUnit.DAYS);
        try {
            Files.walk(cacheDir)
                    .filter(Files::isRegularFile)
                    .filter(p -> {
                        try {
                            return Files.getLastModifiedTime(p).toInstant().isBefore(cutoff);
                        } catch (IOException e) {
                            return false;
                        }
                    })
                    .forEach(p -> {
                        try {
                            Files.delete(p);
                            logger.debug("Removed expired cached image: {}", p.getFileName());
                        } catch (IOException e) {
                            logger.warn("Could not remove expired image {}: {}", p.getFileName(), e.getMessage());
                        }
                    });
        } catch (IOException e) {
            logger.error("Error during scheduled image cache cleanup: {}", e.getMessage());
        }
    }
}
