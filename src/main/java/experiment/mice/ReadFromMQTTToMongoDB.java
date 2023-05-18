package experiment.mice;

import ConectToSql.GetFromCloudSQL;
import com.mongodb.*;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.mongodb.BasicDBObject;


public class ReadFromMQTTToMongoDB implements MqttCallback{
    private static final Logger logger = Logger.getLogger(ReadFromMQTTToMongoDB.class.getName());
    private DBCollection mongocolmov;
    private DBCollection mongocoltemp;
    private DBCollection mongocolwrong;
    private static String mongoUser = "root";
    private static String mongoPassword = "testesenha";
    private static String mongoAddress = "localhost:27015,localhost:25015,localhost:23015";
    private static String mongoReplica = "Sensores";
    private static String mongoDatabase = "sensores";
    private static String cloudTopicMov = "pisid_mazemov";
    private static String cloudTopicTemp = "pisid_mazetemp";
    private static String mongoAuthentication = "false";
    private static final String MONGOCOLLECTIONMOV = "SensoresMovimento";
    private static final String MONGOCOLLECTIONTEMP = "SensoresTemperatura";
    private static final String MONGOCOLLECTIONWRONG = "WrongValues";
    private ArrayList<Double> tempValues = new ArrayList<>();
    private static final String OUTLIER = "Outlier";
    private final JTextArea documentLabel;

    private static int numSalas;
    private static   ArrayList<Integer> salasEntrada;
    private static   ArrayList<Integer> salasSaida;

    private static boolean authenticateUser() {
        String username = JOptionPane.showInputDialog(null, "Enter your username:");
        String password = JOptionPane.showInputDialog(null, "Enter your password:");
        return username.equals("admin") && password.equals("password");
    }

    private ReadFromMQTTToMongoDB() {
        documentLabel = new JTextArea();
    }

    private void createWindow() {

        // Set Look and Feel to make the UI look more modern
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | UnsupportedLookAndFeelException e) {
            logger.log(Level.SEVERE, "Error setting the look and feel", e);
        }

        JFrame frame = new JFrame("Cloud to Mongo");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        JLabel label = new JLabel("Data from broker: ", SwingConstants.CENTER);
        label.setPreferredSize(new Dimension(600, 30));

        JScrollPane scrollPane = new JScrollPane(documentLabel, ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_ALWAYS);
        scrollPane.setPreferredSize(new Dimension(600, 200));

        JButton button = new JButton("Stop the program");
        button.addActionListener(e -> System.exit(0));

        frame.getContentPane().add(label, BorderLayout.NORTH);
        frame.getContentPane().add(scrollPane, BorderLayout.CENTER);
        frame.getContentPane().add(button, BorderLayout.SOUTH);

        frame.setLocationRelativeTo(null);
        frame.pack();
        frame.setVisible(true);
    }

    public static void main(String[] args) throws MqttException {

        boolean authenticated = false;
        while (!authenticated) {
            if (!authenticateUser()) {
                JOptionPane.showMessageDialog(null, "Invalid username or password.");
            } else {
                authenticated = true;
            }
        }

        String server;
        int choice = JOptionPane.showOptionDialog(
                null,
                "Select a server:",
                "Server selection",
                JOptionPane.YES_NO_OPTION,
                JOptionPane.QUESTION_MESSAGE,
                null,
                new Object[] {"Cloud Server", "Local Server"},
                "Cloud Server"
        );

        if (choice == JOptionPane.YES_OPTION) {
            server = "tcp://broker.mqtt-dashboard.com:1883";
            boolean insertNewTopics = JOptionPane.showConfirmDialog(null, "Do you want to insert new topics?", "New Topics", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION;
            if (insertNewTopics) {
                int numTopics = Integer.parseInt(JOptionPane.showInputDialog(null, "Enter the number of new topics:"));
                List<String> newTopics = new ArrayList<>();
                for (int i = 0; i < numTopics; i++) {
                    String topic = JOptionPane.showInputDialog(null, "Enter topic " + (i + 1) + ":");
                    newTopics.add(topic);
                }
                ReadFromMQTTToMongoDB cloudToMongo = new ReadFromMQTTToMongoDB();
                cloudToMongo.createWindow();
                if (!newTopics.isEmpty()) {
                    cloudToMongo.connectToMqttServer(server, newTopics);
                } else {
                    System.out.println("Please provide at least one topic.");
                    System.exit(1);
                }
                cloudToMongo.connectMongo();
            } else {
                ReadFromMQTTToMongoDB cloudToMongo = new ReadFromMQTTToMongoDB();
                cloudToMongo.createWindow();
                cloudToMongo.connectToMqttServer(server, Collections.singletonList(cloudTopicMov));
                cloudToMongo.connectMongo();
            }
        } else {
            server = "tcp://localhost:1883";
            ReadFromMQTTToMongoDB cloudToMongo = new ReadFromMQTTToMongoDB();
            cloudToMongo.createWindow();
            cloudToMongo.connectToMqttServer(server, Collections.singletonList(cloudTopicMov));
            cloudToMongo.connectMongo();
        }

        GetFromCloudSQL getFromCloud = new GetFromCloudSQL();
        getFromCloud.connectDBCloud();
        salasEntrada = getFromCloud.getSalasEntrada();
        salasSaida = getFromCloud.getSalasSaida();
        numSalas = getFromCloud.getNumSalas();
    }

    /**
     * Connects to an MQTT server and subscribes to the specified topics.
     *
     * @param cloudServer the URL of the MQTT server to connect to
     * @param topics      the list of topics to subscribe to
     * @throws MqttException if there is an error connecting to the MQTT server or subscribing to topics
     */
    private void connectToMqttServer(String cloudServer, List<String> topics) throws MqttException {
        final String CLIENT_ID_PREFIX = "CloudToMongo_";
        SecureRandom secureRandom = new SecureRandom();
        int clientId = secureRandom.nextInt(100000);

        try (MqttClient mqttClient = new MqttClient(cloudServer, CLIENT_ID_PREFIX + clientId, new MqttDefaultFilePersistence(System.getProperty("user.dir") + File.separator + "tmp"))) {
            mqttClient.connect();
            mqttClient.setCallback(this);
            for (String topic : topics) {
                mqttClient.subscribe(topic);
            }
        } catch (MqttException e) {
            logger.log(Level.WARNING, "Error connecting to MQTT server: " + e.getMessage());
        }
    }

    public void connectMongo() {
        String mongoURI = "mongodb://";
        if (Boolean.parseBoolean(ReadFromMQTTToMongoDB.mongoAuthentication)) {
            mongoURI += ReadFromMQTTToMongoDB.mongoUser + ":" + ReadFromMQTTToMongoDB.mongoPassword + "@";
        }
        mongoURI += ReadFromMQTTToMongoDB.mongoAddress;

        if (!ReadFromMQTTToMongoDB.mongoReplica.equals("false")) {
            mongoURI += "/?replicaSet=" + ReadFromMQTTToMongoDB.mongoReplica;
            if (Boolean.parseBoolean(ReadFromMQTTToMongoDB.mongoAuthentication)) {
                mongoURI += "&authSource=admin";
            }
        }

        MongoClient mongoClient = new MongoClient(new MongoClientURI(mongoURI));
        DB database = mongoClient.getDB(ReadFromMQTTToMongoDB.mongoDatabase);

        mongocolmov = database.getCollection(MONGOCOLLECTIONMOV);
        mongocoltemp = database.getCollection(MONGOCOLLECTIONTEMP);
        mongocolwrong = database.getCollection(MONGOCOLLECTIONWRONG);
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        try {
            BasicDBObject documentJson = (BasicDBObject) com.mongodb.util.JSON.parse(message.toString());

            if (topic.equals(cloudTopicTemp) && mongocoltemp != null) {
                if (processTemperatureValues(documentJson)) {
                    documentJson.put(OUTLIER, 1);
                    mongocoltemp.insert(documentJson);
                } else {
                    documentJson.put(OUTLIER, 0);
                    mongocoltemp.insert(documentJson);
                }
            } else if (topic.equals(cloudTopicMov) && mongocolmov != null) {
                if(processMovValues(documentJson))
                    mongocolmov.insert(documentJson);
                else{
                    String messageString = new String(message.getPayload());
                    mongocolwrong.insert(new BasicDBObject("topic", topic)
                            .append("message", messageString));

                }

            }


            documentJson.removeField("_id");
            documentLabel.append(documentJson + "\n");

        } catch (NumberFormatException e) {
            try {
                String messageString = new String(message.getPayload());
                mongocolwrong.insert(new BasicDBObject("topic", topic)
                        .append("message", messageString));
            } catch (Exception ex) {
                logger.log(Level.SEVERE, () -> "Error while inserting wrong value into MongoDB: " + ex.getMessage());
            }
        } catch (Exception ex) {
            logger.log(Level.SEVERE, () -> "Error while processing message: " + ex.getMessage());
        }
    }

    private boolean processMovValues(DBObject document){
        int salaEntrada = Integer.parseInt(document.get("SalaEntrada").toString());
        int salaSaida = Integer.parseInt(document.get("SalaSaida").toString());
        boolean result = isValidCorridor(salaEntrada, salaSaida);
        return result;
    }

    private boolean processTemperatureValues(DBObject document) {
        boolean result = false;
        double temp = Double.parseDouble(document.get("Leitura").toString());
        tempValues.add(temp);
        if (tempValues.size() > 10) {
            tempValues.remove(0);
        }

        double[] values = new double[tempValues.size()];
        for (int i = 0; i < tempValues.size(); i++) {
            values[i] = tempValues.get(i);
        }

        double zScore = calculateZScore(values, temp);

        if (Math.abs(zScore) > 2.0) {
            result = true;
        }
        return result;
    }

    /**
     * Calculates the ZScore for a current value of temperature, taking into consideration the previous temperature values.
     * Returns the ZScore which will be used to see if a value is an outlier.
     */
    private double calculateZScore(double[] values, double value) {
        double sum = 0.0;
        for (double v : values) {
            sum += v;
        }
        double mean = sum / values.length;

        double squareSum = 0.0;
        for (double v : values) {
            squareSum += Math.pow(v - mean, 2);
        }
        double stdDev = Math.sqrt(squareSum / (values.length - 1));

        return (value - mean) / stdDev;
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

    public boolean isValidCorridor(int entrada, int saida) {
        boolean result = false;

        if(entrada > numSalas || entrada < 0 || saida   > numSalas || saida   < 0)
                return result;

        for(int i=0; i<salasEntrada.size(); i++) {
            if( salasEntrada.get(i) == entrada && salasSaida.get(i)   == saida) {
                result = true;
                break;
            }
        }
        return result;
    }
}
