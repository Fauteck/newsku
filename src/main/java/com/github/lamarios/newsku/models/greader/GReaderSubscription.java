package com.github.lamarios.newsku.models.greader;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/**
 * A single subscription (feed) as returned by the GReader API
 * endpoint /reader/api/0/subscription/list
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class GReaderSubscription {

    /** e.g. "feed/https://example.com/rss" */
    private String id;
    private String title;
    private String url;
    private String htmlUrl;
    private String iconUrl;
    private List<GReaderLabel> categories;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getHtmlUrl() { return htmlUrl; }
    public void setHtmlUrl(String htmlUrl) { this.htmlUrl = htmlUrl; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }

    public List<GReaderLabel> getCategories() { return categories; }
    public void setCategories(List<GReaderLabel> categories) { this.categories = categories; }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class GReaderLabel {
        /** e.g. "user/-/label/Tech" */
        private String id;
        private String label;

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public String getLabel() { return label; }
        public void setLabel(String label) { this.label = label; }
    }
}
