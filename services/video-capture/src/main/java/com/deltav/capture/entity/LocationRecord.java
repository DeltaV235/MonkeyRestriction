package com.deltav.capture.entity;

import lombok.Data;

@Data
public class LocationRecord {
    private String recordId;
    private String videoId;
    private Long timestamp;
    private Double latitude;
    private Double longitude;
} 