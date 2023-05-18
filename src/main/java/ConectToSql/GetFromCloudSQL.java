package ConectToSql;

import java.util.*;

import java.sql.*;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.DriverManager;

public class GetFromCloudSQL {

    private static String URL = "jdbc:mariadb://194.210.86.10:3306/pisid_2023_maze";
    private static String USER = "aluno";
    private static String PASS = "aluno";
    private  int numSalas = 0;
    private  ArrayList<Integer> salasEntrada;
    private  ArrayList<Integer> salasSaida;

    public   void connectDBCloud(){
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            Connection connection = DriverManager.getConnection(URL, USER, PASS);
            getInfo(connection);
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

    }

    private void getInfo(Connection conn) throws SQLException {
        String getCorridors = "SELECT salaentrada, salasaida FROM corredor";
        String getSalas = "SELECT numerosalas FROM configuraçãolabirinto";
        Statement stmt = conn.createStatement();
        ResultSet configSalas = stmt.executeQuery(getSalas);

        if (configSalas.next()) {
            numSalas = configSalas.getInt("numerosalas");
        }
        configSalas.close();
        stmt.close();

        salasEntrada = new ArrayList<>();
        salasSaida = new ArrayList<>();

        Statement stmt2 = conn.createStatement();
        ResultSet corridors = stmt2.executeQuery(getCorridors);
        while (corridors != null && corridors.next()) {
            salasEntrada.add(corridors.getInt("salaentrada"));
            salasSaida.add(corridors.getInt("salasaida"));
        }
        if(corridors!=null) {
            corridors.close();
        }
        stmt2.close();

        System.out.println(numSalas);
    }

    public ArrayList<Integer> getSalasEntrada(){
        return salasEntrada;
    }

    public ArrayList<Integer> getSalasSaida(){
        return salasSaida;
    }

    public int getNumSalas(){
        return numSalas;
    }
}