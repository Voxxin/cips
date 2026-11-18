package cat.ella.cips;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RestController;

import java.util.logging.Logger;

@SpringBootApplication
@RestController
public class CipsApplication {
	public static void main(String[] args) {
		SpringApplication.run(CipsApplication.class, args);
	}
}