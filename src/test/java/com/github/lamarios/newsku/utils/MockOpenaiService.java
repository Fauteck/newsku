package com.github.lamarios.newsku.utils;

import com.apptasticsoftware.rssreader.Item;
import com.github.lamarios.newsku.models.OpenAiFeedResponse;
import com.github.lamarios.newsku.models.TagClickStat;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.services.OpenaiService;
import org.springframework.context.annotation.Primary;

import java.util.List;
import java.util.Optional;
import java.util.Random;

//@Primary
//@Service
public class MockOpenaiService implements OpenaiService {


    @Primary
    @Override
    public Optional<OpenAiFeedResponse> processFeedItem(Item item, User user, List<TagClickStat> clickStats) {
        return Optional.of(new OpenAiFeedResponse(new Random().nextInt(100), false, "This is a test", List.of("my", "tags"), null, null));
    }

    @Override
    public Optional<OpenAiFeedResponse> processFeedItem(String guid, String title, String content, long articleTimeMs, User user, List<TagClickStat> clickStats) {
        return Optional.of(new OpenAiFeedResponse(new Random().nextInt(100), false, "This is a test", List.of("my", "tags"), null, null));
    }
}
