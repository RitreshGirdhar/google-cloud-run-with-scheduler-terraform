package com.poc.models;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class Weather {

	private String name;
	private Long timestamp;
	private double temperature;
	private Integer weatherId;
	private String weatherIcon;


}
