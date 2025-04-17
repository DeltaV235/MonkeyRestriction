package com.deltav.capture.mapper;

import com.deltav.capture.entity.LocationRecord;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface LocationMapper {
    @Insert("INSERT INTO location_record (record_id, video_id, timestamp, latitude, longitude) " +
            "VALUES (#{recordId}, #{videoId}, #{timestamp}, #{latitude}, #{longitude})")
    void insert(LocationRecord record);
} 