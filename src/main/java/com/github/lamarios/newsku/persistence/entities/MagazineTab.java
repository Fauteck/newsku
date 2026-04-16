package com.github.lamarios.newsku.persistence.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

@Entity
@Table(name = "magazine_tabs")
public class MagazineTab {

    @Id
    private String id;

    private String name;

    @Column(name = "display_order")
    private int displayOrder;

    @Column(name = "is_public")
    private boolean isPublic;

    @Column(name = "ai_preference")
    private String aiPreference;

    @Column(name = "minimum_importance")
    private Integer minimumImportance;

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

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    @JsonProperty("isPublic")
    public boolean isPublic() {
        return isPublic;
    }

    @JsonProperty("isPublic")
    public void setPublic(boolean isPublic) {
        this.isPublic = isPublic;
    }

    public String getAiPreference() {
        return aiPreference;
    }

    public void setAiPreference(String aiPreference) {
        this.aiPreference = aiPreference;
    }

    public Integer getMinimumImportance() {
        return minimumImportance;
    }

    public void setMinimumImportance(Integer minimumImportance) {
        this.minimumImportance = minimumImportance;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
