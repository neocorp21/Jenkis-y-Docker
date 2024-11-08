package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class co {

        @GetMapping("/hola")
        public String hola() {
            return "Hola Mundo  desde Spring Boot Ded 2";
        }
}
