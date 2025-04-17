package com.deltav.capture.mapper;

import com.deltav.capture.entity.VideoSegment;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface VideoSegmentMapper {
    @Insert("INSERT INTO video_segment (segment_id, video_id, segment_path, start_time, end_time, status) " +
            "VALUES (#{segmentId}, #{videoId}, #{segmentPath}, #{startTime}, #{endTime}, #{status})")
    void insert(VideoSegment segment);
    
    VideoSegment selectById(@Param("segmentId") String segmentId);
    
    void updateStatus(@Param("segmentId") String segmentId, @Param("status") String status);
} 