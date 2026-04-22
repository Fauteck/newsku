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
     * Overload for callers that already have plain strings (e.g. GReader sync).
     *
     * @param guid          unique identifier used for logging
     * @param title         article title
     * @param content       article body / description
     * @param articleTimeMs article publication time (epoch ms); used to skip
     *                      pre-activation articles on fresh installations
     */
    Optional<OpenAiFeedResponse> processFeedItem(String guid, String title, String content, long articleTimeMs, User user, List<TagClickStat> clickStats);
}
