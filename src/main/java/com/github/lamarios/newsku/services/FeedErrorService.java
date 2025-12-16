package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedError;
import com.github.lamarios.newsku.persistence.repositories.FeedErrorRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class FeedErrorService {

    private final static Logger logger = LogManager.getLogger();
    private final FeedErrorRepository feedErrorRepository;
    private final FeedRepository feedRepository;
    private final UserService userService;

    @Autowired
    public FeedErrorService(FeedErrorRepository feedErrorRepository, FeedRepository feedRepository, UserService userService) {
        this.feedErrorRepository = feedErrorRepository;
        this.feedRepository = feedRepository;
        this.userService = userService;
    }

    public List<FeedError> getErrors(Feed feed, long from, long to) {
        return feedErrorRepository.findByFeedAndTimeCreatedBetween(feed, from, to);
    }

    public int countErrors(Feed feed, long from, long to) {
        return feedErrorRepository.countByFeedAndTimeCreatedBetween(feed, from, to);
    }

    public Page<FeedError> getPaginatedErrors(Feed feed, int page, int pageSize) {
        return feedErrorRepository.findByFeed(feed, PageRequest.of(page, pageSize, Sort.by(new Sort.Order(Sort.Direction.DESC, "timeCreated"))));
    }

    public long countLast24HoursErrors(){

        var user = userService.getCurrentUser();

        long to = System.currentTimeMillis();
        long from = to - 24 * 60 * 60 * 1000;

        List<Feed> feeds = feedRepository.getFeedsByUser(user);

        return feedErrorRepository.countByFeedInAndTimeCreatedBetween(feeds, from, to);

    }

}
