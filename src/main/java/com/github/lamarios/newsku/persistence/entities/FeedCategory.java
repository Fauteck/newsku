package com.github.lamarios.newsku.persistence.entities;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
@Table(name = "feed_categories")
public class FeedCategory {

    @Id
    private String id;
    private String name;

    @Column(name = "freshrss_category_id")
    private String gReaderCategoryId;


    @ManyToOne
    @JoinColumn(name = "user_id")
    @JsonIgnore
    private User user;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getGReaderCategoryId() {
        return gReaderCategoryId;
    }

    public void setGReaderCategoryId(String gReaderCategoryId) {
        this.gReaderCategoryId = gReaderCategoryId;
    }
}
