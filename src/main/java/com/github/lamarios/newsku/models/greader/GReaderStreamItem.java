package com.github.lamarios.newsku.models.greader;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/**
 * A single article as returned inside the stream contents response.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class GReaderStreamItem {

    /** Full tag URI, e.g. "tag:google.com,2005:reader/item/00000000ab1234ef" */
    private String id;
    private String title;
    private String author;

    /** Unix timestamp in seconds */
    private long published;

    /** Enclosures (images, audio, etc.) */
    private List<Enclosure> enclosure;

    /** Canonical URL list */
    private List<Href> canonical;

    /** Alternate URL list */
    private List<Href> alternate;

    /** Short summary / description */
    private Content summary;

    /** Full article content (may be absent) */
    private Content content;

    /** Feed origin info */
    private Origin origin;

    /** Category tags including state and label strings */
    private List<String> categories;

    // --- nested types ---

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Href {
        private String href;
        private String type;

        public String getHref() { return href; }
        public void setHref(String href) { this.href = href; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Content {
        private String content;
        private String direction;

        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }

        public String getDirection() { return direction; }
        public void setDirection(String direction) { this.direction = direction; }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Origin {
        private String streamId;
        private String title;
        private String htmlUrl;

        public String getStreamId() { return streamId; }
        public void setStreamId(String streamId) { this.streamId = streamId; }

        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }

        public String getHtmlUrl() { return htmlUrl; }
        public void setHtmlUrl(String htmlUrl) { this.htmlUrl = htmlUrl; }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Enclosure {
        private String url;
        private String type;
        private String length;

        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = url; }

        public String getType() { return type; }
        public void setType(String type) { this.type = type; }

        public String getLength() { return length; }
        public void setLength(String length) { this.length = length; }

        public boolean isImage() {
            return type != null && type.startsWith("image/");
        }
    }

    // --- getters/setters ---

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    public long getPublished() { return published; }
    public void setPublished(long published) { this.published = published; }

    public List<Enclosure> getEnclosure() { return enclosure; }
    public void setEnclosure(List<Enclosure> enclosure) { this.enclosure = enclosure; }

    public List<Href> getCanonical() { return canonical; }
    public void setCanonical(List<Href> canonical) { this.canonical = canonical; }

    public List<Href> getAlternate() { return alternate; }
    public void setAlternate(List<Href> alternate) { this.alternate = alternate; }

    public Content getSummary() { return summary; }
    public void setSummary(Content summary) { this.summary = summary; }

    public Content getContent() { return content; }
    public void setContent(Content content) { this.content = content; }

    public Origin getOrigin() { return origin; }
    public void setOrigin(Origin origin) { this.origin = origin; }

    public List<String> getCategories() { return categories; }
    public void setCategories(List<String> categories) { this.categories = categories; }

    /** Returns the article URL (prefers canonical, falls back to alternate) */
    public String resolveUrl() {
        if (canonical != null) {
            return canonical.stream().map(Href::getHref).filter(h -> h != null && !h.isBlank()).findFirst().orElse(null);
        }
        if (alternate != null) {
            return alternate.stream().map(Href::getHref).filter(h -> h != null && !h.isBlank()).findFirst().orElse(null);
        }
        return null;
    }

    /** Returns first image enclosure URL, or null */
    public String resolveImageUrl() {
        if (enclosure == null) return null;
        return enclosure.stream()
                .filter(Enclosure::isImage)
                .map(Enclosure::getUrl)
                .findFirst()
                .orElse(null);
    }

    /** Returns the full article text content (prefers content over summary) */
    public String resolveContent() {
        if (content != null && content.getContent() != null && !content.getContent().isBlank()) {
            return content.getContent();
        }
        if (summary != null && summary.getContent() != null) {
            return summary.getContent();
        }
        return null;
    }
}
