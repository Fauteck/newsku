package com.github.lamarios.newsku.services;

import be.ceau.opml.OpmlParseException;
import be.ceau.opml.OpmlParser;
import be.ceau.opml.OpmlWriteException;
import be.ceau.opml.OpmlWriter;
import be.ceau.opml.entity.Body;
import be.ceau.opml.entity.Head;
import be.ceau.opml.entity.Opml;
import be.ceau.opml.entity.Outline;
import com.apptasticsoftware.rssreader.*;
import com.github.lamarios.newsku.Constants;
import com.github.lamarios.newsku.errors.DuplicateFeedException;
import com.github.lamarios.newsku.errors.NewskuException;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import com.github.lamarios.newsku.utils.TemporaryInvalidXmlCharacterFilter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class FeedService {
    private final UserService userService;
    private final FeedRepository feedRepository;

    private final Logger log = LogManager.getLogger();

    public final static AbstractRssReader<Channel, Item> DEFAULT_READER = new RssReader()
            .setUserAgent(Constants.USER_AGENT)
            .addFeedFilter(new TemporaryInvalidXmlCharacterFilter())
            .addItemExtension("media:thumbnail", "url", (item, s) -> {
                Enclosure enclosure = new Enclosure();
                enclosure.setType("image");
                enclosure.setUrl(s);
                item.addEnclosure(enclosure);
            })
            .addItemExtension("media:content", "url", (item, s) -> {
                if (item.getEnclosure().isEmpty()) {
                    Enclosure enclosure = new Enclosure();
                    enclosure.setType("image");
                    enclosure.setUrl(s);
                    item.addEnclosure(enclosure);
                }
            });

    @Autowired
    public FeedService(UserService userService, FeedRepository feedRepository) {
        this.userService = userService;
        this.feedRepository = feedRepository;
    }


    @Transactional
    @CacheEvict(value = "feedsByUser", allEntries = true)
    public Feed addFeed(String url) throws NewskuException {
        User currentUser = userService.getCurrentUser();

        // Reject duplicate subscriptions before we hit the network: the user
        // already has this URL, so we map this to HTTP 409 with a clear
        // message instead of silently creating a second row.
        var existing = feedRepository.findFirstByUrlAndUser(url, currentUser);
        if (existing != null && !existing.isEmpty()) {
            throw new DuplicateFeedException("Feed already subscribed");
        }

        List<Item> list;
        try {
            list = DEFAULT_READER
                    .read(url)
                    .sorted()
                    .toList();
        } catch (Exception e) {
            throw new NewskuException("Couldn't read feed URL");
        }

        if (list.isEmpty()) {
            throw new NewskuException("Feed is empty");
        }

        var item = list.getFirst().getChannel();

        Feed feed = new Feed();
        feed.setId(UUID.randomUUID().toString());
        feed.setUrl(url);
        feed.setDescription(item.getDescription());
        feed.setImage(item.getImage().map(Image::getUrl).orElse(null));
        feed.setName(item.getTitle());
        feed.setUser(currentUser);

        return feedRepository.save(feed);
    }

    /**
     * Cached per authenticated username — every request chain hits the feed
     * list several times (controllers + services). Short TTL + explicit
     * eviction on mutating calls keeps it fresh (issue B17). The SpEL key
     * reads from the SecurityContext rather than method args because
     * {@code getFeeds()} itself is zero-argument.
     */
    @Cacheable(value = "feedsByUser",
            key = "T(org.springframework.security.core.context.SecurityContextHolder).context.authentication.name")
    @Transactional(readOnly = true)
    public List<Feed> getFeeds() {
        return feedRepository.getFeedsByUser(userService.getCurrentUser());
    }

    @Transactional
    @CacheEvict(value = "feedsByUser", allEntries = true)
    public Feed updateFeed(Feed feed) {

        var oldFeed = feedRepository.getFirstById(feed.getId());
        var user = userService.getCurrentUser();
        if (user.getId().equalsIgnoreCase(oldFeed.getUser().getId())) {
            feed.setUser(oldFeed.getUser());
            return feedRepository.save(feed);
        } else {
            throw new AccessDeniedException("you do not own this feed");
        }
    }

    @Transactional
    @CacheEvict(value = "feedsByUser", allEntries = true)
    public boolean deleteFeed(String id) {
        Feed firstById = feedRepository.getFirstById(id);
        var user = userService.getCurrentUser();

        if (user.getId().equalsIgnoreCase(firstById.getUser().getId())) {
            feedRepository.delete(firstById);
            return true;
        }
        return false;
    }

    public Feed getFeed(String id) {
        return feedRepository.findFirstByIdAndUser(id, userService.getCurrentUser());
    }

    @Transactional
    public List<Feed> importFeed(MultipartFile file) throws NewskuException {
        try {
            log.info("Importing feed");
            var user = userService.getCurrentUser();
            Path tempDirectory = Files.createTempDirectory("newsku-opml-import");
            Path p = tempDirectory.resolve("import.opml");
            file.transferTo(p);
            List<Feed> newFeeds = new ArrayList<>();

            try (var is = new FileInputStream(p.toFile())) {
                var parser = new OpmlParser().parse(is);
                for (Outline outline : parser.getBody().getOutlines()) {
                    newFeeds.addAll(importFeed(outline, user));
                }


                return newFeeds;
            } catch (SQLException | OpmlParseException e) {
                log.error("Failed to parse opml file", e);
                throw new NewskuException("Failed to parse OPML file");
            } finally {
                Files.deleteIfExists(p);
                Files.deleteIfExists(tempDirectory);
            }
        }catch (IOException e) {
            throw  new NewskuException("Failed to read file");
        }
    }

    @Transactional
    public List<Feed> importFeed(Outline outline, User user) throws SQLException, IOException {
        List<Feed> newFeeds = new ArrayList<>();

        Map<String, String> attributes = outline.getAttributes();
        if (attributes.containsKey("type") && attributes.get("type")
                .equalsIgnoreCase("rss") && attributes.containsKey("xmlUrl")) {

            // we check if the feed already exists
            String url = attributes.get("xmlUrl");
            if (feedRepository.findFirstByUrlAndUser(url, user).isEmpty()) {
                try {
                    newFeeds.add(addFeed(url));
                } catch (Exception e) {
                    log.warn("Couldnt parse feed {}", url, e);
                }
            } else {
                log.info("User already has feed {}", url);
            }
        }

        if (!outline.getSubElements().isEmpty()) {
            outline.getSubElements().forEach(outline1 -> {
                try {
                    newFeeds.addAll(importFeed(outline1, user));
                } catch (SQLException | IOException e) {
                    throw new RuntimeException(e);
                }
            });
        }

        return newFeeds;
    }

    @Transactional(readOnly = true)
    public String exportFeed() throws OpmlWriteException {
        List<Feed> feeds = feedRepository.getFeedsByUser(userService.getCurrentUser());

        Head head = new Head("Newsku", LocalDateTime.now()
                .toString(), null, null, null, null, null, null, null, null, null, null, null);

        List<Outline> outlines = feeds.stream()
                .map(feed -> new Outline(Map.of("type", "rss", "xmlUrl", feed.getUrl(), "title", feed.getName()), Collections.emptyList()))
                .toList();

        Body body = new Body(outlines);

        Opml opml = new Opml("2.0", head, body);

        OpmlWriter writer = new OpmlWriter();

        return writer.write(opml);
    }
}
