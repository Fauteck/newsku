package com.github.lamarios.newsku.utils;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;

public class TransactionHelper {
    private final static Logger log = LogManager.getLogger();

    public static void doInNewTransaction(PlatformTransactionManager transactionManager, boolean readonly, Runnable runnable) {
        DefaultTransactionDefinition definition = new DefaultTransactionDefinition();
        definition.setReadOnly(readonly);
        TransactionStatus status = transactionManager.getTransaction(definition);
        try {
            runnable.run();
            transactionManager.commit(status);
        } catch (Exception e) {
            transactionManager.rollback(status);
            // handle exception
            log.error("Failed to run operation within a transaction, rolling back", e);
            throw e;
        }
    }
}
