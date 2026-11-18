package cat.ella.cips.config;

import cat.ella.cips.exception.AdmiRejectionReason;
import cat.ella.cips.exception.GlobalExceptionHandler;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.SecurityFilterChain;

import java.io.IOException;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        AuthenticationEntryPoint entryPoint = (req, res, ex) -> {
            res.setHeader("WWW-Authenticate", "Basic realm=\"cips\"");
            write(res, AdmiRejectionReason.AUTHENTICATION_FAILURE, "Authentication required");
        };
        AccessDeniedHandler denied = (req, res, ex) ->
                write(res, AdmiRejectionReason.AUTHORIZATION_FAILURE, "Access denied");

        http.authorizeHttpRequests(a -> a.anyRequest().authenticated())
                .httpBasic(b -> b.authenticationEntryPoint(entryPoint))
                .exceptionHandling(e -> e.authenticationEntryPoint(entryPoint).accessDeniedHandler(denied))
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .csrf(AbstractHttpConfigurer::disable);
        return http.build();
    }

    private static void write(HttpServletResponse res, AdmiRejectionReason reason, String text) throws IOException {
        res.setStatus(reason.httpStatus());
        res.setContentType(MediaType.APPLICATION_XML_VALUE);
        res.setCharacterEncoding("UTF-8");
        res.getWriter().write(GlobalExceptionHandler.admiToXml(reason, null, text));
    }
}