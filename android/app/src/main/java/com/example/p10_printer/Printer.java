package com.example.p10_printer;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.pos.sdk.printer.POIPrinterManager;
import com.pos.sdk.printer.models.BitmapPrintLine;
import com.pos.sdk.printer.models.PrintLine;
import com.pos.sdk.printer.models.TextPrintLine;

import java.util.ArrayList;
import java.util.List;

public class Printer {
    private static final String TAG = "Printer";

    // Original receipt printing method
    public static void printerTest(Context context) {
        final POIPrinterManager printerManager = new POIPrinterManager(context);
        printerManager.open();
        int state = printerManager.getPrinterState();
        Log.d(TAG, "printer state = " + state);
        
        printerManager.setPrintGray(5);
        printerManager.setLineSpace(5);
        
        String str1 = "This is an example of a receipt";
        PrintLine p1 = new TextPrintLine(str1, PrintLine.CENTER);
        printerManager.addPrintLine(p1);
        
        printerManager.setPrintFont("/system/fonts/ComingSoon.ttf");
        String str2 = "Floor ** , Building **, No.*** LONG DONG Avenue, ວຽງຈັນ New District, Shanghai, China";
        PrintLine p2 = new TextPrintLine(str2, PrintLine.LEFT, 20);
        printerManager.addPrintLine(p2);
        
        printerManager.setPrintFont("/system/fonts/DroidSansMono.ttf");
        List<TextPrintLine> list1 = printList("24 June 2025", "     Assistant 6", "815002", 18, false);
        printerManager.addPrintLine(list1);
        List<TextPrintLine> list2 = printList("Item", "Quantity", "Price", 24, true);
        printerManager.addPrintLine(list2);
        List<TextPrintLine> list3 = printList("Tomato", "1", "$2.08", 24, false);
        printerManager.addPrintLine(list3);
        List<TextPrintLine> list4 = printList("Orange", "1", "$1.06", 24, false);
        printerManager.addPrintLine(list4);
        PrintLine p3 = new TextPrintLine("Total  $3.14", PrintLine.RIGHT);
        printerManager.addPrintLine(p3);
        printerManager.addPrintLine(new TextPrintLine(""));
        printerManager.addPrintLine(new TextPrintLine(""));
        String str3 = "Did you know you could have earned Rewards points on this purchase?";
        PrintLine p4 = new TextPrintLine(str3, PrintLine.CENTER);
        printerManager.addPrintLine(p4);
        PrintLine p5 = new TextPrintLine("Simply sign up today for a Membership Card!", PrintLine.CENTER);
        printerManager.addPrintLine(p5);
        printerManager.addPrintLine(new TextPrintLine(" ", 0, 100));
        
        POIPrinterManager.IPrinterListener listener = new POIPrinterManager.IPrinterListener() {
            @Override
            public void onStart() {
                int newState = printerManager.getPrinterState();
                Log.d(TAG, "new printer state = " + newState);
            }

            @Override
            public void onFinish() {
                int state = printerManager.getPrinterState();
                Log.d(TAG, "printer state = " + state);
                printerManager.close();
            }

            @Override
            public void onError(int code, String msg) {
                Log.e("POIPrinterManager", "code: " + code + "msg: " + msg);
                printerManager.close();
            }
        };
        
        if(state == 4){
            printerManager.close();
            return;
        }
        printerManager.beginPrint(listener);
    }

    // Simple custom text printing method - prints only the text as-is
    public static void printCustomText(Context context, String customText) {
        final POIPrinterManager printerManager = new POIPrinterManager(context);
        printerManager.open();
        int state = printerManager.getPrinterState();
        Log.d(TAG, "printer state = " + state + ", printing custom text: " + customText);
        
        printerManager.setPrintGray(5);
        printerManager.setLineSpace(5);
        
        // Print only the custom text, plain and simple
        PrintLine textLine = new TextPrintLine(customText, PrintLine.LEFT, 24);
        printerManager.addPrintLine(textLine);
        
        // Add some spacing at the end
        printerManager.addPrintLine(new TextPrintLine("", 0, 50));
        
        POIPrinterManager.IPrinterListener listener = new POIPrinterManager.IPrinterListener() {
            @Override
            public void onStart() {
                Log.d(TAG, "Custom text print started");
            }

            @Override
            public void onFinish() {
                Log.d(TAG, "Custom text print finished");
                printerManager.close();
            }

            @Override
            public void onError(int code, String msg) {
                Log.e(TAG, "Custom text print error: " + code + " " + msg);
                printerManager.close();
            }
        };
        
        if(state == 4){
            Log.w(TAG, "Printer state is 4, closing connection");
            printerManager.close();
            return;
        }
        printerManager.beginPrint(listener);
    }

    // Helper method for creating multi-column lists
    private static List<TextPrintLine> printList(String leftStr, String centerStr, String rightStr, int size, boolean bold){
        TextPrintLine textPrintLine1 = new TextPrintLine(leftStr, PrintLine.LEFT, size, bold);
        TextPrintLine textPrintLine2 = new TextPrintLine(centerStr, PrintLine.CENTER, size, bold);
        TextPrintLine textPrintLine3 = new TextPrintLine(rightStr, PrintLine.RIGHT, size, bold);
        List<TextPrintLine> list = new ArrayList<>();
        list.add(textPrintLine1);
        list.add(textPrintLine2);
        list.add(textPrintLine3);
        return list;
    }
}