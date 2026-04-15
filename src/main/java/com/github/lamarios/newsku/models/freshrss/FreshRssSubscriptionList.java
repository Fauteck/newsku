package com.github.lamarios.newsku.models.freshrss;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/** Top-level response from /reader/api/0/subscription/list */
@JsonIgnoreProperties(ignoreUnknown = true)
public class FreshRssSubscriptionList {
    private List<FreshRssSubscription> subscriptions;

    public List<FreshRssSubscription> getSubscriptions() { return subscriptions; }
    public void setSubscriptions(List<FreshRssSubscription> subscriptions) { this.subscriptions = subscriptions; }
}
