package experiment.mice;

import org.eclipse.paho.client.mqttv3.*;

public class MqttToSql {
    // MQTT broker URL
    private static final String BROKER_URL = "tcp://localhost:1883";

    // MQTT topic to subscribe to
    private static final String MQTT_TOPIC = "replicaset-data";

    public static void main(String[] args) throws MqttException {
        // Create an MQTT client
        MqttClient mqttClient = new MqttClient(BROKER_URL, MqttClient.generateClientId());

        // Set up a callback to handle incoming MQTT messages
        mqttClient.setCallback(new MqttCallback() {
            @Override
            public void connectionLost(Throwable throwable) {}

            @Override
            public void messageArrived(String topic, MqttMessage mqttMessage) throws Exception {
                System.out.println("Received message on topic " + topic + ": " + new String(mqttMessage.getPayload()));
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken iMqttDeliveryToken) {}
        });

        // Connect to the MQTT broker
        mqttClient.connect();

        // Subscribe to the "replicaset-data" topic
        mqttClient.subscribe(MQTT_TOPIC);

        // Wait for incoming messages
        while (true) {}
    }
}
