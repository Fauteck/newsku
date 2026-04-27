package com.github.lamarios.newsku.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class StaticContentController {
    @RequestMapping(value = {"/", "/feed", "/stats", "/settings", "/reset-password", "/public/magazine/**"})
    public String serveIndex() {
        return "forward:/index.html";
    }
}
