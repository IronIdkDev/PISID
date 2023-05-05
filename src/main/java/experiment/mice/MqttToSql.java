package experiment.mice;

import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;
import org.json.JSONObject;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MqttToSql implements MqttCallback {
    //MQTT broker and topic information
    private static final String BROKER_URL = "ssl://5893ab818d254bdf8af7ef32f0a96df1.s2.eu.hivemq.cloud:8883";
    private static final String MQTT_USER = "pisid35";
    private static final String MQTT_PASSWORD = "35AhM0@a";
    private static String mqttTopicMov = "sensoresMov";
    private static String mqttTopicTemp = "sensoresTemp";

    private static final Logger logger = Logger.getLogger(MqttToSql.class.getName());
    private final JTextArea documentLabel;

    private MqttToSql(){
        documentLabel = new JTextArea();
    }

    private void createWindow() {
        //Set Look and Feel for the UI
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | UnsupportedLookAndFeelException e) {
            logger.log(Level.SEVERE, "Error setting the look and feel", e);
        }

        JFrame frame = new JFrame("MQTT to SQL");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        JLabel label = new JLabel("Data from broker: ", SwingConstants.CENTER);
        label.setPreferredSize(new Dimension(600, 30));

        JScrollPane scrollPane = new JScrollPane(documentLabel, ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_ALWAYS);
        scrollPane.setPreferredSize(new Dimension(600, 200));

        JButton button = new JButton("Stop/Resume");
        boolean[] isRunning = {true};

        //Add action listener to button to stop/resume message processing
        button.addActionListener(e -> {
            isRunning[0] = !isRunning[0];
            if (isRunning[0]) {
                button.setText("Stop/Resume");
            } else {
                button.setText("Start/Resume");
            }
        });

        frame.getContentPane().add(label, BorderLayout.NORTH);
        frame.getContentPane().add(scrollPane, BorderLayout.CENTER);
        frame.getContentPane().add(button, BorderLayout.SOUTH);

        frame.setLocationRelativeTo(null);
        frame.pack();
        frame.setVisible(true);
    }

    public static void main(String[] args) throws MqttException {
        MqttToSql mqttToSql = new MqttToSql();
        mqttToSql.createWindow();
        mqttToSql.connectToMqttServer(BROKER_URL, mqttTopicMov, mqttTopicTemp, MQTT_USER, MQTT_PASSWORD);
    }

    private void connectToMqttServer(String broker_url, String mqttTopicMov, String mqttTopicTemp, String username, String password) throws MqttException {
        final String CLIENT_ID_PREFIX = "CloudToMongo_";
        final int clientId = 35;

        MqttConnectOptions options = new MqttConnectOptions();
        options.setUserName(username);
        options.setPassword(password.toCharArray());

        try (MqttClient mqttClient = new MqttClient(broker_url, CLIENT_ID_PREFIX + clientId + "_" + mqttTopicMov, new MqttDefaultFilePersistence(System.getProperty("user.dir") + File.separator + "tmp"))) {
            mqttClient.connect(options);
            mqttClient.setCallback(this);
            try {
                mqttClient.subscribe(mqttTopicMov);
                mqttClient.subscribe(mqttTopicTemp);
            } catch (MqttException e) {
                logger.log(Level.SEVERE, "Error subscribing to topics: %s" + e.getMessage());
            }
        } catch (MqttException e) {
            logger.log(Level.WARNING, "Error connecting to MQTT server: %s" + e.getMessage());
        }
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) throws Exception {
        String username = "root";
        String password = "";
        String url = "jdbc:mariadb://localhost:3306/pisid";
        String driver = "com.mysql.jdbc.Driver";
        if (topic.equals(mqttTopicMov)) {
            String payload = message.toString();
            JSONObject jsonObj = new JSONObject(payload);
            String hora = jsonObj.getString("Hour");
            int from = jsonObj.getInt("from");
            int to = jsonObj.getInt("to");
            Connection conn = null;
            try {
                Class.forName(driver);
                conn = DriverManager.getConnection(url, username, password);
                String sql = "INSERT INTO MediçõesPassagens (Hora, SalaEntrada, SalaSaída) VALUES (?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, hora);
                stmt.setInt(2, from);
                stmt.setInt(3, to);
                stmt.executeUpdate();
                logger.log(Level.INFO, "Successfully added the movement message: " + jsonObj);
            } catch (ClassNotFoundException e) {
                logger.log(Level.SEVERE, "Error loading MySQL JDBC driver: {0}", e.getMessage());
            } catch (SQLException e) {
                logger.log(Level.SEVERE, "Error connecting to database: {0}", e.getMessage());
            } finally {
                if (conn != null) {
                    try {
                        conn.close();
                    } catch (SQLException e) {
                        logger.log(Level.WARNING, "Error closing database connection: {0}", e.getMessage());
                    }
                }
            }
        } else if (topic.equals(mqttTopicTemp)) {
            String payload = message.toString();
            JSONObject jsonObj = new JSONObject(payload);
            String hora = jsonObj.getString("Hour");
            double leitura = jsonObj.getDouble("Leitura");
            int sensor = jsonObj.getInt("Sensor");
            Connection conn = null;
            try {
                Class.forName(driver);
                conn = DriverManager.getConnection(url, username, password);
                String sql = "INSERT INTO Temperaturas (Hora, Leitura, Sensor) VALUES (?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, hora);
                stmt.setDouble(2, leitura);
                stmt.setInt(3, sensor);
                stmt.executeUpdate();
                logger.log(Level.INFO, "Successfully added the temperature message: " + jsonObj);
            } catch (ClassNotFoundException e) {
                logger.log(Level.SEVERE, "Error loading MySQL JDBC driver: {0}", e.getMessage());
            } catch (SQLException e) {
                logger.log(Level.SEVERE, "Error connecting to database: {0}", e.getMessage());
            } finally {
                if (conn != null) {
                    try {
                        conn.close();
                    } catch (SQLException e) {
                        logger.log(Level.WARNING, "Error closing database connection: {0}", e.getMessage());
                    }
                }
            }
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
        logger.log(Level.WARNING, "Connection to MQTT broker lost. Reason: {0}", cause.getMessage());
        logger.log(Level.SEVERE, "Stack trace: ", cause);
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        try {
            logger.log(Level.INFO, "Message delivery complete: {0}", token.getMessage());
        } catch (MqttException e) {
            logger.log(Level.SEVERE, "Error getting message from delivery token: {0}", e.getMessage());
        }
    }
}