package club.meterbeater.server.entity;

import lombok.Data;

@Data
public class Payment {

	Customer customer;
	String paymentToken;
	String paymentType;

}
