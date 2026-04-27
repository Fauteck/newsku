package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import jakarta.validation.ConstraintViolationException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import static org.junit.jupiter.api.Assertions.assertThrows;

@Import(TestConfig.class)
public class PageSizeBoundsTest extends TestContainerTest {

    @Autowired
    private FeedItemController feedItemController;

    @Autowired
    private SearchController searchController;

    @Autowired
    private FeedErrorController feedErrorController;

    @Test
    public void feedItemController_rejects_pageSize_above_max() {
        assertThrows(ConstraintViolationException.class,
                () -> feedItemController.getItems(0L, System.currentTimeMillis(), 0, 2001, null, null, null, null));
    }

    @Test
    public void feedItemController_rejects_pageSize_below_min() {
        assertThrows(ConstraintViolationException.class,
                () -> feedItemController.getItems(0L, System.currentTimeMillis(), 0, 0, null, null, null, null));
    }

    @Test
    public void feedItemController_rejects_negative_page() {
        assertThrows(ConstraintViolationException.class,
                () -> feedItemController.getItems(0L, System.currentTimeMillis(), -1, 50, null, null, null, null));
    }

    @Test
    public void searchController_rejects_pageSize_above_max() {
        assertThrows(ConstraintViolationException.class,
                () -> searchController.search("anything", 0, 501));
    }

    @Test
    public void feedErrorController_rejects_pageSize_above_max() {
        assertThrows(ConstraintViolationException.class,
                () -> feedErrorController.getErrors("any-id", 0, 501));
    }
}
