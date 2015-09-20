package club.meterbeater.server.entity;

import java.util.Date;

import lombok.Data;

@Data
public class MemberLog {

	public enum MemberLogType {
		ORDER,
		CANCELLATION,
		ORDER_COMPLETED
	}

	public MemberLog() {};

	public MemberLog(Date date, MemberLogType type) {
		this.updated = date;
		this.type = type;
	}

	private Date updated;
	private MemberLogType type;


}
