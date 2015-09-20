package club.meterbeater.server.entity;

import java.util.Date;

import lombok.Data;

@Data
public class Request {

	public Request() {}

	private Double lat;
	private Double lon;
	private Integer minutes;
	private Long customerId;

}
