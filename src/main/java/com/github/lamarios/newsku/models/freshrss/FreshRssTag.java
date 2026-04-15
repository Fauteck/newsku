package com.github.lamarios.newsku.models.freshrss;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * A tag/label as returned by /reader/api/0/tag/list
 * Only entries with type "folder" or no type are user-defined categories.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FreshRssTag {
    /** e.g. "user/-/label/Tech" */
    private String id;
    private String sortid;
    private String type;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getSortid() { return sortid; }
    public void setSortid(String sortid) { this.sortid = sortid; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    /** Extract human-readable label from "user/-/label/SomeName" */
    public String getLabel() {
        if (id == null) return null;
        int idx = id.lastIndexOf('/');
        return idx >= 0 ? id.substring(idx + 1) : id;
    }

    public boolean isUserLabel() {
        return id != null && id.contains("/label/");
    }
}
