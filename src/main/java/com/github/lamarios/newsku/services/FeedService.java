package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Image;
import com.apptasticsoftware.rssreader.Item;
import com.apptasticsoftware.rssreader.RssReader;
import com.apptasticsoftware.rssreader.filter.InvalidXmlCharacterFilter;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@Service
public class FeedService {
    private final UserService userService;
    private final FeedRepository feedRepository;


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
}
