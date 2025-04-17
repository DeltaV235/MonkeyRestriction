package com.deltav.capture.service;

import com.deltav.capture.entity.LocationRecord;
import com.deltav.capture.mapper.LocationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class LocationService {
    @Autowired
    private LocationMapper locationMapper;
    
    public void recordLocation(String videoId, double latitude, double longitude) {
        LocationRecord record = new LocationRecord();
        record.setRecordId(generateRecordId());
        record.setVideoId(videoId);
        record.setTimestamp(System.currentTimeMillis());
        record.setLatitude(latitude);
        record.setLongitude(longitude);
        
        locationMapper.insert(record);
    }
    
    private String generateRecordId() {
        return java.util.UUID.randomUUID().toString();
    }
} 