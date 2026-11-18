package cat.ella.cips.messaging;

import cat.ella.cips.exception.GlobalExceptionHandler;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

public class ApiEndpointTest {
    MockMvc mockMvc;

    @BeforeEach
    void prep() {
        mockMvc = MockMvcBuilders.
                standaloneSetup(new ApiController())
                .setControllerAdvice(new GlobalExceptionHandler()
                ).build();
    }

    @Test
    void acceptValidPain001() throws Exception {
        mockMvc.perform(post("/api").contentType(MediaType.TEXT_XML).content(ApiEndpointTest.class.getResourceAsStream("/xml/pain.001.001.09/valid.xml").readAllBytes()))
                .andExpect(status().isAccepted());
    }

    @Test
    void rejectsXmlWithUnknownNamespace() throws Exception {
        String string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<Document xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.999.001.01\"> </Document>";

        mockMvc.perform(post("/api").contentType(MediaType.TEXT_XML).content(string))
                .andExpect(status().isUnprocessableContent())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_XML))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Unsupported message type")));
    }

    @Test
    void rejectsMalformedXml() throws Exception {
        mockMvc.perform(post("/api").contentType(MediaType.TEXT_XML).content("<Document><oops>"))
                .andExpect(status().isBadRequest())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Malformed XML")));
    }

    @Test
    void rejectsEmptyBody() throws Exception {
        mockMvc.perform(post("/api").contentType(MediaType.TEXT_XML))
                .andExpect(status().isBadRequest())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Malformed XML")));
    }

    @Test
    void rejectsWrongContentType() throws Exception {
        mockMvc.perform(post("/api").contentType(MediaType.APPLICATION_JSON).content("{}"))
                .andExpect(status().isUnsupportedMediaType())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Unsupported message type")));
    }

    @Test
    void rejectsWrongMethod() throws Exception {
        mockMvc.perform(get("/api"))
                .andExpect(status().isMethodNotAllowed())
                .andExpect(header().exists("Allow"))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Method not allowed")));
    }

    @Test
    void rejectsUnknownPath() throws Exception {
        mockMvc.perform(post("/nope").contentType(MediaType.TEXT_XML).content("<a/>"))
                .andExpect(status().isNotFound())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Unsupported endpoint")));
    }
}