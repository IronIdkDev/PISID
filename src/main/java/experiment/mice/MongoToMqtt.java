package experiment.mice;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.util.logging.Logger;

public class MongoToMqtt {

    private static final Logger logger = Logger.getLogger(ReadFromMQTTToMongoDB.class.getName());
    private static final MqttClient mqttclient;
    private static final String BROKER_URL = "tcp://localhost:1883";
    // MongoDB collections to read data from
    private static final String[] COLLECTIONS = {"Outliers", "SensoresMovimento", "SensoresTemperatura"};


    static {
        try {
            mqttclient = new MqttClient(BROKER_URL, MqttClient.generateClientId(), new MqttDefaultFilePersistence(System.getProperty("user.dir") + File.separator+ "tmp"));
        } catch (MqttException e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) {
        String mov_data = "mongo_mov_data";
        String temp_data = "mongo_mov_data";

        // Create the MQTT client
        try {
            mqttclient.connect();
        } catch (MqttException e) {
            e.printStackTrace();
            return;
        }

        JTextArea textArea = getjTextArea();

    }

    private static JTextArea getjTextArea() {
        // Create the JFrame and buttons
        JFrame frame = new JFrame("Write to MQTT");
        JTextArea textArea = new JTextArea(20, 100);
        textArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        frame.getContentPane().add(new JScrollPane(textArea), BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout());
        JButton stopButton = new JButton("Stop Sending Data");
        JButton startButton = new JButton("Start Sending Data");
        buttonPanel.add(stopButton);
        buttonPanel.add(startButton);
        frame.getContentPane().add(buttonPanel, BorderLayout.SOUTH);

        frame.pack();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);
        frame.setLocationRelativeTo(null);
        return textArea;
    }

}