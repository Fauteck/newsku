package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.controllers.FeedController;
import com.github.lamarios.newsku.errors.NewskuException;
import com.github.lamarios.newsku.models.EmailDigestFrequency;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import com.github.lamarios.newsku.utils.MockEmailService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import java.util.Arrays;
import java.util.List;

import static com.github.lamarios.newsku.Constants.ONE_DAY_MS;
import static org.junit.jupiter.api.Assertions.*;

@Import(TestConfig.class)
public class EmailDigestServiceTest extends TestContainerTest {
    private final UserService userService;
    private final EmailDigestService emailDigestService;
    private final UserRepository userRepository;
    private final EmailService emailService;

    private final FeedController feedController;
    private final FeedItemService feedItemService;

    @Autowired
    public EmailDigestServiceTest(UserService userService, EmailDigestService emailDigestService, UserRepository userRepository, EmailService emailService, FeedController feedController, FeedItemService feedItemService) {
        this.userService = userService;
        this.emailDigestService = emailDigestService;
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.feedController = feedController;
        this.feedItemService = feedItemService;
    }


    @BeforeEach
    public void setUp() {
        setUserSchedule();
    }

    @Test
    public void testDigest() throws NewskuException {
        var feed = feedController.addFeed("https://feeds.arstechnica.com/arstechnica/index");

        feedItemService.refreshFeedWorker(feed);

        emailDigestService.sendMonthlyDigest();

        // we then check out email queue and see what we have;
        var email = ((MockEmailService) emailService).getEmails().poll();
        assertNotNull(email);

        @SuppressWarnings("unchecked") var items = (List<FeedItem>) email.data().get("items");
        assertTrue(items.size() <= 10);

        var fromTime = System.currentTimeMillis() - (EmailDigestFrequency.monthly.getDays() * ONE_DAY_MS);
        assertTrue(items.stream().allMatch(feedItem -> feedItem.getTimeCreated() > fromTime));
    }

    private void setUserSchedule() {

        // we set our user to have the monthly digest
        var user = userService.getCurrentUser();
        assertNull(user.getEmailDigest());

        user.setEmailDigest(Arrays.stream(EmailDigestFrequency.values()).toList());
        userService.updateUser(user);

        user = userRepository.findFirstById(user.getId());

        assertEquals(3, user.getEmailDigest().size());
    }
}
