package com.github.lamarios.newsku.models.freshrss;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/**
 * Top-level response from /reader/api/0/stream/contents/...
 * The "continuation" token is present when more items are available (pagination).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FreshRssStreamContents {
    private String id;
    private String title;
    private List<FreshRssStreamItem> items;

    /** Pagination cursor – null/absent when no more pages */
    private String continuation;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public List<FreshRssStreamItem> getItems() { return items; }
    public void setItems(List<FreshRssStreamItem> items) { this.items = items; }

    public String getContinuation() { return continuation; }
    public void setContinuation(String continuation) { this.continuation = continuation; }
}
