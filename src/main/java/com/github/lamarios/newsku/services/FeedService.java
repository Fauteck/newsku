package com.github.lamarios.newsku.services;

import be.ceau.opml.OpmlParseException;
import be.ceau.opml.OpmlParser;
import be.ceau.opml.OpmlWriteException;
import be.ceau.opml.OpmlWriter;
import be.ceau.opml.entity.Body;
import be.ceau.opml.entity.Head;
import be.ceau.opml.entity.Opml;
import be.ceau.opml.entity.Outline;
import com.apptasticsoftware.rssreader.Image;
import com.apptasticsoftware.rssreader.Item;
import com.apptasticsoftware.rssreader.RssReader;
import com.apptasticsoftware.rssreader.filter.InvalidXmlCharacterFilter;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
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

    @Autowired
    public FeedService(UserService userService, FeedRepository feedRepository) {
        this.userService = userService;
        this.feedRepository = feedRepository;
    }


    @Transactional
    public Feed addFeed(String url) throws SQLException, IOException {
        User currentUser = userService.getCurrentUser();

        var reader = new RssReader();
        List<Item> list = reader.addFeedFilter(new InvalidXmlCharacterFilter())
                .read(url)
                .sorted()
                .toList();

        if (list.isEmpty()) {
            throw new RuntimeException("Feed is empty");
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

    @Transactional(readOnly = true)
    public List<Feed> getFeeds() throws SQLException {
        return feedRepository.getFeedsByUser(userService.getCurrentUser());
    }

    @Transactional
    public Feed updateFeed(Feed feed) throws SQLException {

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
    public boolean deleteFeed(String id) throws SQLException {
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
    public List<Feed> importFeed(MultipartFile file) throws IOException, OpmlParseException, SQLException {
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
            throw e;
        } finally {
            Files.deleteIfExists(p);
            Files.deleteIfExists(tempDirectory);
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
