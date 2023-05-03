package experiment.mice;

import javax.swing.*;
import java.awt.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Main {
    private static final Logger logger = Logger.getLogger(Main.class.getName());

    public static void main(String[] args) {
        JFrame frame = new JFrame("Start the program");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        frame.setSize(300, 300);
        frame.setLayout(new BorderLayout());
        JButton button = new JButton("Start the Program");
        button.setForeground(Color.WHITE);
        button.setBackground(Color.RED);
        button.setOpaque(true);
        button.setBorderPainted(false);
        button.setPreferredSize(new Dimension(100, 100));
        button.addActionListener(e -> {
            try {
                String[] command = {"cmd.exe", "/c", "runas", "/user:Administrator", "cmd.exe", "/c", "cd \\ && cd mosquitto && net stop mosquitto && net start mosquitto && start cmd /k mosquitto -v -c testconfig.txt"};
                ProcessBuilder builder = new ProcessBuilder(command);
                builder.redirectErrorStream(true);
                builder.start();
            } catch (Exception ex) {
                logger.log(Level.SEVERE, "An exception occurred", ex);
            }
        });
        frame.add(button, BorderLayout.CENTER);
        frame.setVisible(true);
    }
}