using HtmlAgilityPack;
using SharpSvn;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.ServiceModel.Syndication;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;

namespace Apache
{
    public class project{
        public project(String n, String a, String svn, String jira) { Name = n; Address = a; SVN = svn; JIRA = jira; }
        public String Name = "";
        public String Address = "";
        public String SVN = "";
        public String JIRA = "";
    }

    public class ticket {
        public ticket(string n, string p, string a, string pid, string pna) { project = n; priority = p; attachmentURL = a; patchid = pid; patchName = pna; }
        public ticket(string p, string pid, string bug, string f) { project = p; patchid = pid; bugNumber = bug; file = f; }
        public string project;
        string priority;
        string attachmentURL;
        public string patchid;
        string patchName;
        public string file;
        public string bugNumber;        
        public string toString() {
            return project + "," + patchid + "," + patchName + "," + priority + "," + attachmentURL;
        }
    }

    class ApacheToolbox
    {
        static void Main(string[] args)
        {
            //List<project> Projects = retreive_java_software_list();
            //checkoutCode(Projects);            
            //scrape_bugs(Projects);
            //reformat(@"E:\Users\Kent\Documents\Visual Studio 2012\Projects\Apache Scraper\Apache Scraper\bin\debug", @"F:\new\");
            //count(@"F:\");
            //downloadTickets(@"F:\tickets\new\",@"F:\tickets\new\data\");
            //downloadSVNFromFile(@"F:\Places.txt");
            //scrape_bugs_from_file(@"F:\JIRA.txt");
            //get_file_names_from_bugs(@"F:\tickets\new\data",@"F:\tickets\new\ticket_bug_count.txt");
            Console.Out.WriteLine();
        }

        static char bell = (char)7;
        static char male = (char)11;

        public static void scrape_bugs_from_file(string file) {
            var files = File.ReadAllText(file).Split('\n');
            List<project> Projects = new List<project>();
            foreach (string f in files)
            {
                string[] fparts = f.Replace("\r", "").Split(',');
                fparts[1] = fparts[1].Trim();
                Projects.Add(new project(fparts[0],"","",fparts[1]));
            }
            scrape_bugs(Projects);       
        }

        public static void downloadSVNFromFile(string file){
            var files = File.ReadAllText(file).Split('\n');
            using (SvnClient client = new SvnClient())
            {
                foreach (string f in files)
                {
                    Console.Out.WriteLine(f + " started.");
                    try
                    {
                        string[] fparts = f.Replace("\r", "").Split(',');
                        client.CheckOut(new Uri(fparts[0]), Directory.GetCurrentDirectory() + "\\missed\\" + fparts[1]);
                        Console.Out.WriteLine(f + " completed.");
                    }
                    catch { Console.Out.WriteLine(f + " failed."); }
                }
            }
        }

        /// <summary>
        /// Downloads JIRA Ticket information and saves in file
        /// </summary>
        /// <param name="dir"></param>
        public static void downloadTickets(string dir, string output_dir)
        {
            foreach (string file in Directory.EnumerateFiles(dir))
            {
                foreach (string line in File.ReadLines(file))
                {
                    string[] data = line.Split(',');
                    WebClient Client = new WebClient();
                    string ticketNo = data[data.Length - 1];
                    Client.DownloadFileAsync(new Uri("https://issues.apache.org/jira/secure/attachment/" + ticketNo + "/"), output_dir + data[0] + "_" + ticketNo + ".txt");
                    Thread.Sleep(500);
                }
            }
        }

        /// <summary>
        ///  Downloads JIRA Ticket Patches
        /// </summary>
        /// <param name="Projects"></param>
        /// <returns></returns>
        public static List<project> scrape_bugs(List<project> Projects) {
            string priority, a, patchname, patchid;
            foreach (project p in Projects)
            {
                try
                {
                    if (p.JIRA.Contains(@"https://issues.apache.org/jira/browse/"))
                    {
                        string project = p.JIRA.Replace(@"https://issues.apache.org/jira/browse/", "");
                        string xmlString = @"https://issues.apache.org/jira/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?jqlQuery=project+%3D+" + project + "+AND+issuetype+%3D+Bug+AND+status+%3D+Closed+AND+%22Attachment+count%22+%3E%3D+%221%22+ORDER+BY+priority+DESC&tempMax=1000";
                        XmlDocument doc = new XmlDocument();
                        doc.Load(xmlString);

                        using (System.IO.StreamWriter wfile = new System.IO.StreamWriter(@"F:\tickets\new\" + p.Name + ".txt"))
                        {
                            foreach (XmlNode item in doc.SelectNodes("/rss/channel/item"))
                            {
                                priority = item["priority"].Attributes[0].Value;
                                a = "";
                                patchname = item["key"].InnerText;
                                patchid = item["key"].Attributes[0].Value;
                                int count = item["attachments"].ChildNodes.Count;
                                if (count > 0)

                                    foreach (XmlNode attachment in item["attachments"].ChildNodes)
                                    {
                                        a = attachment.Attributes[0].Value;
                                        if (a != "")
                                            wfile.WriteLine(new ticket(p.Name, priority, a, patchid, patchname).toString());
                                    }
                                Console.Out.WriteLine();


                            }
                        }
                    }
                }
                catch { Console.Out.WriteLine("Failed" +p); }
            }
            return null;
        }

        public static List<ticket> get_file_names_from_bugs(string dir, string output_dir) {            
            string text="";
            var regex = new Regex(@"[a-zA-Z]{2,}\.java");            
            string [] projectData=new string[2];
            //int bugs=0;
            List<ticket> Ticket_Data = new List<ticket>();
            foreach (string file in Directory.EnumerateFiles(dir))
            {
                projectData = file.Split('_');
                text = File.ReadAllText(file);
                
                var matches = regex.Matches(text);
                var uniqueMatches = matches.OfType<Match>().Select(m => m.Value).Distinct();

                //bugs = uniqueMatches.Count();
                foreach (var m in uniqueMatches.ToList()){
                    Ticket_Data.Add(new ticket(projectData[0].Replace(dir+@"\",""), projectData[1].Replace(".txt",""), "1",m));
                }             
            }
            using (System.IO.StreamWriter wfile = new System.IO.StreamWriter(output_dir))
            {
                foreach (ticket t in Ticket_Data) {
                    Console.Out.WriteLine(t.project + "," + t.patchid + "," + t.file + "," + t.bugNumber);
                    wfile.WriteLine(t.project+","+t.patchid+","+t.file+","+t.bugNumber);
                }
            }

            return Ticket_Data;
        }

        /// <summary>
        /// Gets a list of projects on Apache's site
        /// </summary>
        /// <returns></returns>
        public static List<project> retreive_java_software_list()
        {
            List<project> Projects = new List<project>();
            string Address = "http://projects.apache.org/indexes/language.html";

            HtmlDocument doc = new HtmlDocument();
            string data = getData(Address);
            doc.LoadHtml(data);

            HtmlNodeCollection Languages = doc.DocumentNode.SelectNodes("//div[@class=\"section\"]");

            int count = 0;
            if (Languages != null)
                foreach (HtmlNode l in Languages)
                {
                    
                    if (l.ChildNodes[1].ChildNodes[2].InnerText == "Java")
                        foreach (HtmlNode project in l.ChildNodes[3].ChildNodes)
                            if (project.ChildNodes.Count > 1)
                            {
                                String projectName = project.ChildNodes[1].InnerText;
                                Console.Out.WriteLine(projectName);
                                String projectAddress = project.ChildNodes[1].Attributes[0].Value;
                                Console.Out.WriteLine(projectAddress);

                                HtmlDocument ProjectPage = new HtmlDocument();
                                ProjectPage.LoadHtml(getData("http://projects.apache.org/" + projectAddress));
                                String SVN = "";
                                HtmlNodeCollection SVNLocation = ProjectPage.DocumentNode.SelectNodes("/html[1]/body[1]/div[2]/table[1]/tr[1]/td[2]/div[1]/div[1]/div[3]/table[1]/tr[2]/td[2]/a[1]");
                                if (SVNLocation != null)
                                {
                                    SVN = SVNLocation[0].InnerText;
                                    Console.Out.WriteLine(SVN);                                    
                                }
                                String JIRA = "";
                                HtmlNodeCollection JIRALocation = ProjectPage.DocumentNode.SelectNodes("/html[1]/body[1]/div[2]/table[1]/tr[1]/td[2]/div[1]/table[1]/tr[4]/td[2]/a[1]");
                                if (SVNLocation != null)
                                {
                                    JIRA=JIRALocation[0].InnerText;
                                    Console.Out.WriteLine(JIRA);                                    
                                }

                                Projects.Add(new project(projectName, projectAddress, SVN, JIRA));
                                count++;
                                
                            }
                    
                }            
            Console.Out.Write(count);            
            return Projects;
        }

        /// <summary>
        /// Gets the SVN Project
        /// </summary>
        /// <param name="Projects"></param>
        public static void checkoutCode(List<project> Projects)
        {
            using (SvnClient client = new SvnClient())
            {
                foreach (project p in Projects)
                    // Checkout the code to the specified directory
                    try { Directory.GetDirectories(Directory.GetCurrentDirectory() + "\\" + p.Name); }
                    catch{
                        try
                        {
                            client.CheckOut(new Uri(p.SVN), Directory.GetCurrentDirectory() + "\\" + p.Name);
                        }
                        catch {Console.Out.WriteLine("Couldn't write: " + p.Name); }
                    }
            }
        }

        /// <summary>
        /// Counts the file lines in a directory
        /// </summary>
        /// <param name="dir"></param>
        public static void count(string dir)
        {
            int count = 0;
            foreach (string file in Directory.EnumerateFiles(dir))
            {
                if (file.Contains(".txt"))
                {
                    Console.Out.WriteLine(file +", "+ count);
                    foreach (string line in File.ReadLines(file))
                        count++;
                }
            }
            Console.Out.WriteLine(count);
            Console.ReadKey();
        }

        /// <summary>
        /// Counts the file lines in a directory
        /// </summary>
        /// <param name="dir"></param>
        public static void countLinesParsedFile(string dir)
        {
            int count = 0;
            foreach (string file in Directory.EnumerateFiles(dir))
            {
                if (file.Contains(".txt"))
                {
                    Console.Out.WriteLine(file + ", " + count);
                    foreach (string line in File.ReadLines(file))
                        count++;
                }
            }
            Console.Out.WriteLine(count);
            Console.ReadKey();
        }


        /// <summary>
        /// Reformats the data so that it can be read into pig
        /// </summary>
        public static void reformat(string DirectoryOfData, string output_dir)
        {
            //@"E:\Users\Kent\Documents\Visual Studio 2012\Projects\new\"
            int Count = 0;

            foreach (string d in Directory.EnumerateDirectories(DirectoryOfData))
            {
                string dir = d.Replace(DirectoryOfData, "");
                using (System.IO.StreamWriter wfile = new System.IO.StreamWriter(output_dir + dir + ".txt"))
                {
                    foreach (string file in Directory.EnumerateFiles(DirectoryOfData + dir, "*.java", SearchOption.AllDirectories))
                    {
                        try
                        {
                            wfile.Write(dir.Replace("\\", ""));
                            wfile.Write(bell);
                            foreach (string line in File.ReadLines(file))
                            {
                                wfile.Write(line);
                                wfile.Write(male);
                                Count += 1;
                            }
                            wfile.Write('\n');
                        }
                        catch { }
                    }
                }
                Console.Out.WriteLine(Count);
            }
            Console.Out.WriteLine();

        }

        /// <summary>
        /// Downloads data from the web.
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string getData(string url)
        {
            string data = "";
            using (WebClient client = new WebClient())
            {
                try
                {
                    data = client.DownloadString(url);
                }
                catch (Exception e)
                {
                    Console.Out.WriteLine(e);
                }

            }
            return data;
        }

    }
}
