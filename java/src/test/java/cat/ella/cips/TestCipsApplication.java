package cat.ella.cips;

import org.springframework.boot.SpringApplication;

public class TestCipsApplication {

	public static void main(String[] args) {
		SpringApplication.from(CipsApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
