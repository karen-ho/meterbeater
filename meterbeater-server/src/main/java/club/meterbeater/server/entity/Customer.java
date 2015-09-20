package club.meterbeater.server.entity;

import java.util.List;

import com.google.common.collect.Lists;

import lombok.Data;

@Data
public class Customer {

	private Long id;
	private String name;
	private String plateNumber;
	private String vehicleImgUrl;
	private List<MemberLog> memberLogs = Lists.newArrayList();
	private Integer money;
	private String magnetUsername;

}
