package com.github.lamarios.newsku.persistence.entities;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "feed_items")
public class FeedItem {

    @Id
    private String id;
    private String guid;
    private String title;
    private String description;
    private String content;
    private String reasoning;
    private String imageUrl;
    private int importance;
    private String url;

    /** AI-generated short-form title tailored for compact grid cards. */
    @Column(name = "short_title")
    private String shortTitle;

    /** AI-generated short-form teaser tailored for compact grid cards. */
    @Column(name = "short_teaser")
    private String shortTeaser;
    @Column(name = "timecreated")
    private long timeCreated;
    private boolean read;
    private boolean saved;

    /**
     * Epoch-millis at which the item was last marked as saved. Set automatically
     * by {@link #setSaved(boolean)} so callers (UI toggle, GReader starred sync)
     * never have to remember it. Null when the item has never been saved.
     */
    @Column(name = "saved_at")
    private Long savedAt;

    @Column(name = "freshrss_item_id")
    private String gReaderItemId;

    @ManyToOne
    @JoinColumn(name = "feed_id")
    private Feed feed;

    @JdbcTypeCode(SqlTypes.ARRAY)
    private List<String> tags;

    public Feed getFeed() {
        return feed;
    }

    public void setFeed(Feed feed) {
        this.feed = feed;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getGuid() {
        return guid;
    }

    public void setGuid(String guid) {
        this.guid = guid;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getReasoning() {
        return reasoning;
    }

    public void setReasoning(String reasoning) {
        this.reasoning = reasoning;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getImportance() {
        return importance;
    }

    public void setImportance(int importance) {
        this.importance = importance;
    }

    public long getTimeCreated() {
        return timeCreated;
    }

    public void setTimeCreated(long timecreated) {
        this.timeCreated = timecreated;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public boolean isSaved() {
        return saved;
    }

    public void setSaved(boolean saved) {
        if (saved && !this.saved) {
            this.savedAt = System.currentTimeMillis();
        } else if (!saved) {
            this.savedAt = null;
        }
        this.saved = saved;
    }

    public Long getSavedAt() {
        return savedAt;
    }

    public void setSavedAt(Long savedAt) {
        this.savedAt = savedAt;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getGReaderItemId() {
        return gReaderItemId;
    }

    public void setGReaderItemId(String gReaderItemId) {
        this.gReaderItemId = gReaderItemId;
    }

    public String getShortTitle() {
        return shortTitle;
    }

    public void setShortTitle(String shortTitle) {
        this.shortTitle = shortTitle;
    }

    public String getShortTeaser() {
        return shortTeaser;
    }

    public void setShortTeaser(String shortTeaser) {
        this.shortTeaser = shortTeaser;
    }
}
