import java.io.*;

public class PackedFileConverter
{
    public static void main(String[] params)
    {
        if (params.length < 4 || params.length > 5 || (!params[0].equals("bb") && !params[0].equals("lc")))
        {
            System.out.println("Usage:\njava PackedFileConverter bb|lc [safety-margin] unpacked_infile packed_infile outfile.");
        }
        else
        {
            if (params.length == 4)
            {
                new PackedFileConverter(params[0], 3, params[1], params[2], params[3]);
            }
            else
            {
                new PackedFileConverter(params[0], Integer.parseInt(params[1]), params[2], params[3], params[4]);
            }
        }
    }

    PackedFileConverter(String packer, int safety_margin, String unpackedInFileName, String packedInFileName, String outFileName)
    {
        readPackedInFile(packer, packedInFileName);
        readUnpackedInFile(packer, unpackedInFileName);
        convertPackedInFile(packer, safety_margin);
        writeOutFile(outFileName);
    }    

    void readPackedInFile(String packer, String packedInFileName)
    {
        FileInputStream packedInFile = null;
        try
        {
            packedInFile = new FileInputStream(packedInFileName);
        }
        catch (IOException e)
        {
            System.out.println(packedInFileName + " couldn't be opened.");
            System.exit(-1);
        }

        try
        {
            _packedFileData = new byte[65536];
            _packedInFileLength = 0;
            
            if (packer.equals("bb"))
            {
                packedInFile.read();
                packedInFile.read();
            }

            int value;
            int i = 2;
            while ((value = packedInFile.read()) != -1)
            {
                _packedFileData[i++] = (byte) value;
            }
            packedInFile.close();
            _packedInFileLength = i;
        }
        catch (IOException e)
        {
            System.out.println( "IO error while reading " + packedInFileName + "." );
            System.exit(-1);
        }
    }

    void readUnpackedInFile(String packer, String unpackedInFileName)
    {
        FileInputStream unpackedInFile = null;
        try
        {
            unpackedInFile = new FileInputStream(unpackedInFileName);
        }
        catch (IOException e)
        {
            System.out.println(unpackedInFileName + " couldn't be opened.");
            System.exit(-1);
        }

        try
        {
            _unpackedInFileLength = 0;

            _unpackedInFileLoadAddress = unpackedInFile.read() | (unpackedInFile.read() << 8);

            int value;
            int i = 2;
            while ((value = unpackedInFile.read()) != -1)
            {
                i++;
            }
            unpackedInFile.close();
            _unpackedInFileLength = i;
        }
        catch (IOException e)
        {
            System.out.println( "IO error while reading " + unpackedInFileName + "." );
            System.exit(-1);
        }
    }

    void convertPackedInFile(String packer, int safety_margin)
    {
        int packedLoadAddress = _unpackedInFileLoadAddress + _unpackedInFileLength + safety_margin - _packedInFileLength;
        
        _packedFileData[0] = (byte) packedLoadAddress;
        _packedFileData[1] = (byte) (packedLoadAddress >> 8);
    }

    void writeOutFile(String outFileName)
    {
        FileOutputStream outFile = null;
        try
        {
            outFile = new FileOutputStream(outFileName);
        }
        catch (IOException e)
        {
            System.out.println(outFile + " couldn't be opened.");
            System.exit(-1);
        }
        
        try
        {
            for (int i = 0; i < _packedInFileLength; i++)
            {
                outFile.write(_packedFileData[i]);
            }
            
            outFile.close();
        }
        catch (IOException e)
        {
            System.out.println("IO error while writing " + outFileName + ".");
            System.exit(-1);
        }        
    }
    
    private byte[] _packedFileData = null;
    private int _unpackedInFileLoadAddress;
    private int _packedInFileLength;
    private int _unpackedInFileLength;
}
