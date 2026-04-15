package com.github.lamarios.newsku.models.freshrss;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/** Top-level response from /reader/api/0/tag/list */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FreshRssTagList {
    private List<FreshRssTag> tags;

    public List<FreshRssTag> getTags() { return tags; }
    public void setTags(List<FreshRssTag> tags) { this.tags = tags; }
}
