package com.github.lamarios.newsku.models.greader;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/** Top-level response from /reader/api/0/subscription/list */
@JsonIgnoreProperties(ignoreUnknown = true)
public class GReaderSubscriptionList {
    private List<GReaderSubscription> subscriptions;

    public List<GReaderSubscription> getSubscriptions() { return subscriptions; }
    public void setSubscriptions(List<GReaderSubscription> subscriptions) { this.subscriptions = subscriptions; }
}
