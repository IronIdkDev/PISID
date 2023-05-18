package experiment.mice;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Main {
    private static final Logger logger = Logger.getLogger(Main.class.getName());
    private static final String PROGRAM_START = "Start the Program";

    public static void main(String[] args) {
        startUIAndAuthentication();
    }

    private static boolean authenticateUser() {
        String username = JOptionPane.showInputDialog(null, "Enter your username:");
        String password = JOptionPane.showInputDialog(null, "Enter your password:");
        return username.equals("admin") && password.equals("password");
    }

    private static void startUIAndAuthentication() {
        boolean authenticated = false;

        while (!authenticated) {
            authenticated = authenticateUser();

            if (authenticated) {
                JFrame frame = new JFrame(PROGRAM_START);
                frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
                frame.setSize(500, 500);
                frame.setLayout(new BorderLayout());

                CircularButton button = new CircularButton(PROGRAM_START, Color.GREEN);
                button.addActionListener(e -> {
                    if (button.getText().equals(PROGRAM_START)) {
                        try {
                            startServers(button);
                        } catch (IOException ioException) {
                            logger.log(Level.SEVERE, "Error starting the program", ioException);
                        }
                    } else {
                        try {
                            stopServers(button);
                        } catch (IOException ioException) {
                            logger.log(Level.SEVERE, "Error stopping the program", ioException);
                        }
                    }
                });

                JPanel panel = new JPanel();
                panel.setLayout(new BoxLayout(panel, BoxLayout.X_AXIS));
                panel.setOpaque(false);
                panel.setAlignmentX(Component.CENTER_ALIGNMENT);
                panel.setAlignmentY(Component.CENTER_ALIGNMENT);
                panel.add(Box.createHorizontalGlue());
                panel.add(button);
                panel.add(Box.createHorizontalGlue());

                frame.add(Box.createVerticalGlue(), BorderLayout.CENTER);
                frame.add(panel, BorderLayout.CENTER);
                frame.setLocationRelativeTo(null);
                frame.setVisible(true);
            } else {
                JOptionPane.showMessageDialog(null, "Invalid username or password.");
            }
        }
    }

    private static void stopServers(CircularButton button) throws IOException {
        String[] sensorsCommand = {"cmd.exe", "/c", "TASKKILL /F /FI \"WINDOWTITLE eq Server S1\" /T && TASKKILL /F /FI \"WINDOWTITLE eq Server S2\" /T && TASKKILL /F /FI \"WINDOWTITLE eq Server S3\" /T"};
        ProcessBuilder sensorsBuilder = new ProcessBuilder(sensorsCommand);
        sensorsBuilder.redirectErrorStream(true);
        sensorsBuilder.start();
        button.setText(PROGRAM_START);
        button.setColor(Color.GREEN);
    }

    private static void startServers(CircularButton button) throws IOException {
        //Runs the sensores_init.bat file to run the servers
        String sensorsInit = "sensores_init";
        String cmd = "cmd.exe";
        String[] sensorsCommand = {cmd, "/c", "cd C:\\Users\\wilio\\Documents\\GitHub\\PISID\\ReplicaSet_MongoDB && " + sensorsInit + ".bat"};
        ProcessBuilder sensorsBuilder = new ProcessBuilder(sensorsCommand);
        sensorsBuilder.redirectErrorStream(true);
        sensorsBuilder.start();
        //Changes the Button's text and color
        button.setText("Stop the Program");
        button.setColor(Color.RED);
    }

    static class CircularButton extends JButton {
        private Color color;

        public CircularButton(String label, Color color) {
            super(label);
            this.color = color;
            setContentAreaFilled(false);
            setFocusPainted(false);
            setBorderPainted(false);
            setOpaque(false);
            setFont(getFont().deriveFont(24f));
            setForeground(Color.WHITE);
            setHorizontalTextPosition(SwingConstants.CENTER);
            setVerticalTextPosition(SwingConstants.CENTER);
        }

        public void setColor(Color color) {
            this.color = color;
            repaint();
        }

        @Override
        protected void paintComponent(Graphics g) {
            Graphics2D g2 = (Graphics2D) g.create();
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            int width = getWidth();
            int height = getHeight();
            GradientPaint gradient = new GradientPaint(0, 0, color.darker(), width, height, color.brighter());
            g2.setPaint(gradient);
            g2.fillRoundRect(0, 0, width - 1, height - 1, 50, 50);
            super.paintComponent(g);
            g2.dispose();
        }
    }
}