using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Text;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Helpers
{
    internal static class MisExcelBuilder
    {
        public static byte[] Build(AcrMisReportResponse report, string tab)
        {
            string normalizedTab = NormalizeTab(tab);

            string sheetName;
            List<RowData> rows;
            switch (normalizedTab)
            {
                case "role":
                    sheetName = "Role-wise MIS";
                    rows = BuildRoleRows(report.RoleWise ?? new List<AcrMisRoleSummary>());
                    break;
                case "details":
                    sheetName = "Application Details";
                    var details = report.Details == null || report.Details.Items == null
                        ? Enumerable.Empty<AcrMisDetailItem>()
                        : report.Details.Items;
                    rows = BuildDetailRows(details);
                    break;
                default:
                    sheetName = "Summary";
                    rows = BuildSummaryRows(report.Summary ?? new AcrMisSummary());
                    break;
            }

            using (var ms = new MemoryStream())
            {
                using (var archive = new ZipArchive(ms, ZipArchiveMode.Create, true))
                {
                    AddEntry(archive, "[Content_Types].xml", ContentTypesXml());
                    AddEntry(archive, "_rels/.rels", RootRelsXml());
                    AddEntry(archive, "docProps/core.xml", CorePropsXml(sheetName));
                    AddEntry(archive, "docProps/app.xml", AppPropsXml(sheetName));
                    AddEntry(archive, "xl/workbook.xml", WorkbookXml(sheetName));
                    AddEntry(archive, "xl/_rels/workbook.xml.rels", WorkbookRelsXml());
                    AddEntry(archive, "xl/styles.xml", StylesXml());
                    AddEntry(archive, "xl/worksheets/sheet1.xml", WorksheetXml(rows));
                }

                return ms.ToArray();
            }
        }

        public static string GetFileNamePrefix(string tab)
        {
            switch (NormalizeTab(tab))
            {
                case "role": return "ACR_MIS_RoleWise";
                case "details": return "ACR_MIS_ApplicationDetails";
                default: return "ACR_MIS_Summary";
            }
        }

        private static string NormalizeTab(string tab)
        {
            if (string.IsNullOrWhiteSpace(tab)) return "summary";
            switch (tab.Trim().ToLowerInvariant())
            {
                case "role":
                case "role-wise":
                case "rolewise":
                    return "role";
                case "details":
                case "application":
                case "application-details":
                    return "details";
                default:
                    return "summary";
            }
        }

        private static List<RowData> BuildSummaryRows(AcrMisSummary summary)
        {
            var rows = new List<RowData>();
            rows.Add(Row(2, "Summary"));
            rows.Add(Row(3, "Total ACR", "Draft", "In Workflow", "Approved", "Rejected", "Auto Forwarded"));
            rows.Add(Row(0, summary.TotalAcr, summary.Draft, summary.InWorkflow, summary.Approved, summary.Rejected, summary.AutoForwarded));
            return rows;
        }

        private static List<RowData> BuildRoleRows(List<AcrMisRoleSummary> roles)
        {
            var rows = new List<RowData>();
            rows.Add(Row(2, "Role-wise MIS"));
            rows.Add(Row(3, "Role", "Created", "Draft", "Submitted", "Received", "Completed", "Pending", "Auto Forwarded", "Approved", "Rejected"));
            foreach (var role in roles)
            {
                rows.Add(Row(0, role.RoleName, role.Created, role.Draft, role.Submitted, role.Received, role.Completed, role.Pending, role.AutoForwarded, role.Approved, role.Rejected));
            }
            return rows;
        }

        private static List<RowData> BuildDetailRows(IEnumerable<AcrMisDetailItem> details)
        {
            var rows = new List<RowData>();
            rows.Add(Row(2, "Detailed Application-wise MIS"));
            rows.Add(Row(3,
                "ACR ID",
                "Employee Name",
                "Designation",
                "Form Type",
                "ACR Year",
                "Location",
                "CCA Name",
                "Reporting Manager 1",
                "Reporting Manager 2",
                "Reviewing Manager",
                "Accepting Manager",
                "Current Status",
                "CCA Submitted Date",
                "Officer Submitted Date",
                "RM1 Submitted Date",
                "RM2 Submitted Date",
                "Reviewing Submitted Date",
                "Accepting Decision Date",
                "Final Decision",
                "Current Pending With",
                "Current Stage Age",
                "Age Bucket",
                "Auto Forwarded / Skipped"));

            bool hasRows = false;
            foreach (var item in details)
            {
                hasRows = true;
                rows.Add(Row(0,
                    item.AcrId,
                    WithLogin(item.EmployeeName, item.EmployeeLoginId),
                    item.Designation,
                    item.FormType,
                    item.AcrYear,
                    item.Location,
                    item.CcaName,
                    item.ReportingManager1Name,
                    item.ReportingManager2Name,
                    item.ReviewingManagerName,
                    item.AcceptingManagerName,
                    item.CurrentStatus,
                    item.CcaSubmittedDate,
                    item.OfficerSubmittedDate,
                    item.Rm1SubmittedDate,
                    item.Rm2SubmittedDate,
                    item.ReviewingSubmittedDate,
                    item.AcceptingDecisionDate,
                    item.FinalDecision,
                    item.CurrentPendingWith,
                    item.CurrentStageAgeDays + " day(s)",
                    item.CurrentStageAgeBucket,
                    item.IsAutoForwarded ? item.AutoForwardedStages : "No"));
            }

            if (!hasRows)
                rows.Add(Row(0, "No applications matched the selected filters."));

            return rows;
        }

        private static string WorksheetXml(List<RowData> rows)
        {
            var sb = new StringBuilder();
            sb.Append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>");
            sb.Append("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">");
            sb.Append("<dimension ref=\"").Append(DimensionRef(rows)).Append("\"/>");
            sb.Append("<sheetViews><sheetView workbookViewId=\"0\"><pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/></sheetView></sheetViews>");
            sb.Append("<sheetFormatPr defaultRowHeight=\"15\"/>");
            sb.Append("<cols>");
            for (int i = 1; i <= 30; i++)
                sb.Append("<col min=\"").Append(i).Append("\" max=\"").Append(i).Append("\" width=\"22\" customWidth=\"1\"/>");
            sb.Append("</cols>");
            sb.Append("<sheetData>");

            for (int r = 0; r < rows.Count; r++)
            {
                int rowIndex = r + 1;
                sb.Append("<row r=\"").Append(rowIndex).Append("\">");
                var row = rows[r];
                for (int c = 0; c < row.Values.Count; c++)
                {
                    string cellRef = ColumnName(c + 1) + rowIndex;
                    AddCellXml(sb, cellRef, row.Values[c], row.StyleId);
                }
                sb.Append("</row>");
            }

            sb.Append("</sheetData></worksheet>");
            return sb.ToString();
        }

        private static void AddCellXml(StringBuilder sb, string cellRef, object value, int styleId)
        {
            bool isNumber = value is int || value is long || value is decimal || value is double || value is float;
            sb.Append("<c r=\"").Append(cellRef).Append("\" s=\"").Append(styleId).Append("\"");
            if (!isNumber) sb.Append(" t=\"inlineStr\"");
            sb.Append(">");

            if (isNumber)
            {
                sb.Append("<v>").Append(Convert.ToString(value, System.Globalization.CultureInfo.InvariantCulture)).Append("</v>");
            }
            else
            {
                sb.Append("<is><t>").Append(Xml(value == null ? "-" : value.ToString())).Append("</t></is>");
            }

            sb.Append("</c>");
        }

        private static string DimensionRef(List<RowData> rows)
        {
            int maxCols = rows.Count == 0 ? 1 : Math.Max(1, rows.Max(r => r.Values.Count));
            int rowCount = Math.Max(1, rows.Count);
            return "A1:" + ColumnName(maxCols) + rowCount;
        }

        private static string CorePropsXml(string sheetName)
        {
            string now = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ");
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<cp:coreProperties xmlns:cp=\"http://schemas.openxmlformats.org/package/2006/metadata/core-properties\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
                + "<dc:title>ACR Portal MIS Report - " + Xml(sheetName) + "</dc:title>"
                + "<dc:creator>ACR Portal</dc:creator>"
                + "<cp:lastModifiedBy>ACR Portal</cp:lastModifiedBy>"
                + "<dcterms:created xsi:type=\"dcterms:W3CDTF\">" + now + "</dcterms:created>"
                + "<dcterms:modified xsi:type=\"dcterms:W3CDTF\">" + now + "</dcterms:modified>"
                + "</cp:coreProperties>";
        }

        private static string AppPropsXml(string sheetName)
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Properties xmlns=\"http://schemas.openxmlformats.org/officeDocument/2006/extended-properties\" xmlns:vt=\"http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes\">"
                + "<Application>ACR Portal</Application>"
                + "<DocSecurity>0</DocSecurity>"
                + "<ScaleCrop>false</ScaleCrop>"
                + "<HeadingPairs><vt:vector size=\"2\" baseType=\"variant\"><vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant><vt:variant><vt:i4>1</vt:i4></vt:variant></vt:vector></HeadingPairs>"
                + "<TitlesOfParts><vt:vector size=\"1\" baseType=\"lpstr\"><vt:lpstr>" + Xml(sheetName) + "</vt:lpstr></vt:vector></TitlesOfParts>"
                + "<LinksUpToDate>false</LinksUpToDate>"
                + "<SharedDoc>false</SharedDoc>"
                + "<HyperlinksChanged>false</HyperlinksChanged>"
                + "<AppVersion>16.0000</AppVersion>"
                + "</Properties>";
        }

        private static string WorkbookXml(string sheetName)
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">"
                + "<sheets>"
                + "<sheet name=\"" + Xml(sheetName) + "\" sheetId=\"1\" r:id=\"rId1\"/>"
                + "</sheets></workbook>";
        }

        private static string WorkbookRelsXml()
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
                + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>"
                + "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"
                + "</Relationships>";
        }

        private static string RootRelsXml()
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
                + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>"
                + "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties\" Target=\"docProps/core.xml\"/>"
                + "<Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties\" Target=\"docProps/app.xml\"/>"
                + "</Relationships>";
        }

        private static string ContentTypesXml()
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
                + "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
                + "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
                + "<Override PartName=\"/docProps/core.xml\" ContentType=\"application/vnd.openxmlformats-package.core-properties+xml\"/>"
                + "<Override PartName=\"/docProps/app.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.extended-properties+xml\"/>"
                + "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"
                + "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
                + "<Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
                + "</Types>";
        }

        private static string StylesXml()
        {
            return "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
                + "<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">"
                + "<fonts count=\"4\"><font><sz val=\"11\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"18\"/><color rgb=\"FF102542\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"11\"/><color rgb=\"FFFFFFFF\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"12\"/><color rgb=\"FF102542\"/><name val=\"Calibri\"/></font></fonts>"
                + "<fills count=\"4\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill><fill><patternFill patternType=\"solid\"><fgColor rgb=\"FF102542\"/><bgColor indexed=\"64\"/></patternFill></fill><fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFE2E8F0\"/><bgColor indexed=\"64\"/></patternFill></fill></fills>"
                + "<borders count=\"2\"><border><left/><right/><top/><bottom/><diagonal/></border><border><left style=\"thin\"><color rgb=\"FFCBD5E1\"/></left><right style=\"thin\"><color rgb=\"FFCBD5E1\"/></right><top style=\"thin\"><color rgb=\"FFCBD5E1\"/></top><bottom style=\"thin\"><color rgb=\"FFCBD5E1\"/></bottom><diagonal/></border></borders>"
                + "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
                + "<cellXfs count=\"4\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"1\" xfId=\"0\" applyBorder=\"1\"/><xf numFmtId=\"0\" fontId=\"1\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyFont=\"1\"/><xf numFmtId=\"0\" fontId=\"3\" fillId=\"3\" borderId=\"1\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\"/><xf numFmtId=\"0\" fontId=\"2\" fillId=\"2\" borderId=\"1\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\"/></cellXfs>"
                + "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>"
                + "</styleSheet>";
        }

        private static void AddEntry(ZipArchive archive, string path, string content)
        {
            var entry = archive.CreateEntry(path, CompressionLevel.Fastest);
            using (var writer = new StreamWriter(entry.Open(), new UTF8Encoding(false)))
            {
                writer.Write(content);
            }
        }

        private static RowData Row(params object[] values)
        {
            return Row(0, values);
        }

        private static RowData Row(int styleId, params object[] values)
        {
            return new RowData { StyleId = styleId, Values = values.ToList() };
        }

        private static string ColumnName(int columnNumber)
        {
            var dividend = columnNumber;
            var columnName = string.Empty;
            while (dividend > 0)
            {
                var modulo = (dividend - 1) % 26;
                columnName = Convert.ToChar(65 + modulo) + columnName;
                dividend = (dividend - modulo) / 26;
            }
            return columnName;
        }

        private static string WithLogin(string name, string loginId)
        {
            if (string.IsNullOrWhiteSpace(loginId)) return Safe(name);
            return Safe(name) + " (" + loginId + ")";
        }

        private static string Xml(string value)
        {
            return WebUtility.HtmlEncode(Safe(value));
        }

        private static string Safe(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : value;
        }

        private class RowData
        {
            public int StyleId { get; set; }
            public List<object> Values { get; set; }
        }
    }
}
