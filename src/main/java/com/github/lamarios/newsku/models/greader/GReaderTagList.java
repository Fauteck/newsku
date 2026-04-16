package com.github.lamarios.newsku.models.greader;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/** Top-level response from /reader/api/0/tag/list */
@JsonIgnoreProperties(ignoreUnknown = true)
public class GReaderTagList {
    private List<GReaderTag> tags;

    public List<GReaderTag> getTags() { return tags; }
    public void setTags(List<GReaderTag> tags) { this.tags = tags; }
}
