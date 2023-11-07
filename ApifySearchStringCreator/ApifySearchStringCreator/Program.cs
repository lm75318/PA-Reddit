using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using OfficeOpenXml;

namespace ApifySearchStringCreator
{
  internal class Program
  {
    static void Main(string[] args)
    {
      string basePath = @"";// Path for post-file.xlsx


      string[] subDirectories = Directory.GetDirectories(basePath);
      foreach (string subDir in subDirectories)
      {
        string[] xlsxFiles = Directory.GetFiles(subDir, "*.xlsx");
        string inputFilePath = "";
        if (xlsxFiles.Length == 0)
        {
          Console.WriteLine("Keine .xlsx-Datei im Verzeichnis" + subDir + " gefunden.");
          return;
        }
        else if (xlsxFiles.Length == 1)
        {
          inputFilePath = xlsxFiles[0];

          Console.WriteLine("Einzige .xlsx-Datei im Verzeichnis gefunden: " + inputFilePath);
        }
        else
        {
          Console.WriteLine("Mehrere .xlsx-Dateien im Verzeichnis gefunden. Bitte wählen Sie eine aus oder passen Sie das Programm entsprechend an.");
        }

        try
        {
          using (var package = new ExcelPackage(new FileInfo(inputFilePath)))
          {
            ExcelWorksheet worksheet = package.Workbook.Worksheets[0];

            int rowCount = worksheet.Dimension.Rows;
            int colCount = worksheet.Dimension.Columns;

            string urlsStringPosts = "";
            string urlsStringUsers = "";

            // Auslesen der URLs und Zusammenfügen zu einem String
            for (int row = 2; row <= rowCount; row++)
            {
              string postUrl = worksheet.Cells[row, 16].Value?.ToString(); // Annahme, dass die URLs in der ersten Spalte sind (Spalte A)
              if (!string.IsNullOrEmpty(postUrl))
              {
                urlsStringPosts += "{\"url\":\"";
                urlsStringPosts += postUrl;
                urlsStringPosts += "\"},\n";
              }

              string userUrl = worksheet.Cells[row, 17].Value?.ToString(); // Annahme, dass die URLs in der ersten Spalte sind (Spalte A)
              if (!string.IsNullOrEmpty(userUrl))
              {
                urlsStringUsers += "{\"url\":\"https://www.reddit.com/user/";
                urlsStringUsers += userUrl;
                urlsStringUsers += "\"},\n";
              }
            }

            urlsStringPosts = urlsStringPosts.Remove(urlsStringPosts.Length - 2);
            urlsStringUsers = urlsStringUsers.Remove(urlsStringUsers.Length - 2);

            // Schreiben des Strings in die .txt-Datei
            File.WriteAllText(subDir + "/posts.txt", urlsStringPosts);
            File.WriteAllText(subDir + "/users.txt", urlsStringUsers);


            Console.WriteLine("Die URLs wurden erfolgreich in die .txt-Datei geschrieben.");
          }
        }
        catch (Exception ex)
        {
          Console.WriteLine("Fehler beim Lesen der Excel-Datei: " + ex.Message);
        }
      }
    }
  }
}