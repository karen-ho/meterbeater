package club.meterbeater.server.entity;

import java.util.Date;

import lombok.Data;

@Data
public class Order {

	private static Long ORDER_ID_COUNTER = 0L;

	private Long id = ++ORDER_ID_COUNTER;
	private Double lat;
	private Double lon;
	private Date expiration;
	private Customer customer;

}
