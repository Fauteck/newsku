package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Item;
import com.github.lamarios.newsku.models.OpenAiFeedResponse;
import com.github.lamarios.newsku.models.TagClickStat;
import com.github.lamarios.newsku.persistence.entities.User;

import java.util.List;
import java.util.Optional;

public interface OpenaiService {
    Optional<OpenAiFeedResponse> processFeedItem(Item item, User user, List<TagClickStat> clickStats);

    /**
     * Overload for callers that already have plain strings (e.g. FreshRSS sync).
     *
     * @param guid    unique identifier used for logging
     * @param title   article title
     * @param content article body / description
     */
    Optional<OpenAiFeedResponse> processFeedItem(String guid, String title, String content, User user, List<TagClickStat> clickStats);
}
