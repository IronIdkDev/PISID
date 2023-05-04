package experiment.mice;

import javax.swing.*;
import org.eclipse.paho.client.mqttv3.*;

public class MqttToSql {
    private static final String BROKER_URL = "ssl://5893ab818d254bdf8af7ef32f0a96df1.s2.eu.hivemq.cloud:8883";
    private static final String MQTT_TOPIC = "sensoresData";
    private static final String MQTT_USER = "pisid35";
    private static final String MQTT_PASSWORD = "35AhM0@a";

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            JFrame frame = new JFrame("MQTT to SQL");
            JTextArea textArea = new JTextArea(20, 40);
            textArea.setEditable(false);
            frame.getContentPane().add(new JScrollPane(textArea));
            frame.pack();
            frame.setVisible(true);

            MqttClient mqttClient = null;
            try {
                mqttClient = new MqttClient(BROKER_URL, MqttClient.generateClientId());
                MqttConnectOptions options = new MqttConnectOptions();
                options.setUserName(MQTT_USER);
                options.setPassword(MQTT_PASSWORD.toCharArray());
                options.setCleanSession(true);
                mqttClient.connect(options);
                mqttClient.subscribe(MQTT_TOPIC, (topic, message) -> {
                    String payload = new String(message.getPayload());
                    textArea.append(payload + "\n");
                });
            } catch (MqttException e) {
                e.printStackTrace();
            }

            if (mqttClient != null && mqttClient.isConnected()) {
                try {
                    mqttClient.disconnect();
                } catch (MqttException e) {
                    e.printStackTrace();
                }
            }
            try {
                if (mqttClient != null) {
                    mqttClient.close();
                }
            } catch (MqttException e) {
                e.printStackTrace();
            }
        });
    }
}