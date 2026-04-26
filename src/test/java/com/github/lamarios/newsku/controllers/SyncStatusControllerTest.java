package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.models.SyncStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

@Import(TestConfig.class)
public class SyncStatusControllerTest extends TestContainerTest {

    @Autowired
    private SyncStatusController syncStatusController;

    @Test
    public void freshUser_reportsNeverRun() {
        var response = syncStatusController.getStatus();
        assertEquals(SyncStatus.NEVER_RUN, response.status());
        assertNull(response.lastSyncTime());
        assertNull(response.errorMessage());
    }
}
