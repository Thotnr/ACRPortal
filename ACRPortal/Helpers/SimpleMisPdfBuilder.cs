using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Helpers
{
    internal static class SimpleMisPdfBuilder
    {
        private const double PageWidth = 842;
        private const double PageHeight = 595;
        private const double Margin = 34;

        public static byte[] Build(AcrMisReportResponse report)
        {
            var pages = Paginate(BuildLines(report));
            var objects = new List<string>();
            int fontObjectId = 3 + (pages.Count * 2);

            objects.Add("<< /Type /Catalog /Pages 2 0 R >>");
            objects.Add("<< /Type /Pages /Kids [ " + string.Join(" ", Enumerable.Range(0, pages.Count).Select(i => (3 + i * 2) + " 0 R")) + " ] /Count " + pages.Count + " >>");

            for (int i = 0; i < pages.Count; i++)
            {
                int contentObjectId = 4 + (i * 2);
                objects.Add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 842 595] /Resources << /Font << /F1 " + fontObjectId + " 0 R >> >> /Contents " + contentObjectId + " 0 R >>");
                string stream = PageStream(pages[i]);
                objects.Add("<< /Length " + Encoding.ASCII.GetByteCount(stream) + " >>\nstream\n" + stream + "\nendstream");
            }

            objects.Add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
            return WritePdf(objects);
        }

        private static List<Line> BuildLines(AcrMisReportResponse report)
        {
            var lines = new List<Line>();
            var filters = report.AppliedFilters ?? new AcrMisAppliedFilters();
            var summary = report.Summary ?? new AcrMisSummary();

            Add(lines, "ACR Portal MIS Report", 18);
            Add(lines, "Generated: " + DateTime.Now.ToString("dd-MMM-yyyy HH:mm"), 9);
            AddWrapped(lines, "Filters: Year=" + Safe(filters.AcrYear) + "; Form Type=" + Safe(filters.FormType) + "; Location=" + Safe(filters.Location) + "; Employee=" + Safe(filters.Employee) + "; Status=" + Safe(filters.Status) + "; Search=" + Safe(filters.Search), 120, 8);
            Add(lines, "", 8);

            Add(lines, "Summary", 13);
            AddWrapped(lines, "Total ACR: " + summary.TotalAcr + " | Draft: " + summary.Draft + " | In Workflow: " + summary.InWorkflow + " | Approved: " + summary.Approved + " | Rejected: " + summary.Rejected + " | Auto Forwarded: " + summary.AutoForwarded, 130, 9);
            Add(lines, "", 8);

            Add(lines, "Role-wise MIS", 13);
            foreach (var role in report.RoleWise ?? new List<AcrMisRoleSummary>())
            {
                AddWrapped(lines, role.RoleName + ": Created " + role.Created + ", Draft " + role.Draft + ", Submitted " + role.Submitted + ", Received " + role.Received + ", Completed " + role.Completed + ", Pending " + role.Pending + ", Auto Forwarded " + role.AutoForwarded + ", Approved " + role.Approved + ", Rejected " + role.Rejected, 130, 8);
            }
            Add(lines, "", 8);

            Add(lines, "Application Details", 13);
            AddWrapped(lines, "ACR ID | Employee | Dsg | Type | Year | Location | Status | CCA | Officer | RM1 | RM2 | Reviewing | Decision | Pending With | Age | Skipped", 145, 7);
            var items = report.Details == null || report.Details.Items == null ? new List<AcrMisDetailItem>() : report.Details.Items;
            foreach (var item in items)
            {
                AddWrapped(lines,
                    Short(item.AcrId, 8) + " | " + Short(item.EmployeeName, 16) + " | " + Safe(item.Designation) + " | " + Safe(item.FormType) + " | " + item.AcrYear + " | " + Short(item.Location, 16) + " | " + Safe(item.CurrentStatus) + " | " + Safe(item.CcaSubmittedDate) + " | " + Safe(item.OfficerSubmittedDate) + " | " + Safe(item.Rm1SubmittedDate) + " | " + Safe(item.Rm2SubmittedDate) + " | " + Safe(item.ReviewingSubmittedDate) + " | " + Safe(item.FinalDecision) + " | " + Short(item.CurrentPendingWith, 16) + " | " + item.CurrentStageAgeDays + "d | " + Safe(item.AutoForwardedStages),
                    150, 7);
            }
            if (!items.Any()) Add(lines, "No applications matched the selected filters.", 9);
            return lines;
        }

        private static List<List<Line>> Paginate(List<Line> lines)
        {
            var pages = new List<List<Line>>();
            var page = new List<Line>();
            double y = PageHeight - Margin;
            foreach (var line in lines)
            {
                if (y < Margin + 12)
                {
                    pages.Add(page);
                    page = new List<Line>();
                    y = PageHeight - Margin;
                }
                page.Add(line);
                y -= line.Size + 4;
            }
            if (page.Count > 0) pages.Add(page);
            return pages.Count == 0 ? new List<List<Line>> { new List<Line> { new Line("ACR Portal MIS Report", 18) } } : pages;
        }

        private static string PageStream(List<Line> lines)
        {
            var sb = new StringBuilder("BT\n");
            double y = PageHeight - Margin;
            foreach (var line in lines)
            {
                sb.Append("/F1 ").Append(line.Size.ToString(CultureInfo.InvariantCulture)).Append(" Tf\n");
                sb.Append("0.08 0.13 0.22 rg\n");
                sb.Append("1 0 0 1 ").Append(Margin.ToString(CultureInfo.InvariantCulture)).Append(" ").Append(y.ToString("0.##", CultureInfo.InvariantCulture)).Append(" Tm\n");
                sb.Append("(").Append(Escape(line.Text)).Append(") Tj\n");
                y -= line.Size + 4;
            }
            sb.Append("ET");
            return sb.ToString();
        }

        private static byte[] WritePdf(List<string> objects)
        {
            var sb = new StringBuilder("%PDF-1.4\n");
            var offsets = new List<int> { 0 };
            for (int i = 0; i < objects.Count; i++)
            {
                offsets.Add(Encoding.ASCII.GetByteCount(sb.ToString()));
                sb.Append(i + 1).Append(" 0 obj\n").Append(objects[i]).Append("\nendobj\n");
            }
            int xref = Encoding.ASCII.GetByteCount(sb.ToString());
            sb.Append("xref\n0 ").Append(objects.Count + 1).Append("\n0000000000 65535 f \n");
            for (int i = 1; i < offsets.Count; i++) sb.Append(offsets[i].ToString("0000000000", CultureInfo.InvariantCulture)).Append(" 00000 n \n");
            sb.Append("trailer\n<< /Size ").Append(objects.Count + 1).Append(" /Root 1 0 R >>\nstartxref\n").Append(xref).Append("\n%%EOF");
            return Encoding.ASCII.GetBytes(sb.ToString());
        }

        private static void Add(List<Line> lines, string text, int size) { lines.Add(new Line(text, size)); }

        private static void AddWrapped(List<Line> lines, string text, int max, int size)
        {
            text = Safe(text);
            while (text.Length > max)
            {
                int split = text.LastIndexOf(' ', Math.Min(max, text.Length - 1));
                if (split <= 0) split = max;
                Add(lines, text.Substring(0, split).Trim(), size);
                text = text.Substring(split).Trim();
            }
            Add(lines, text, size);
        }

        private static string Short(string value, int max)
        {
            value = Safe(value);
            return value.Length <= max ? value : value.Substring(0, Math.Max(0, max - 3)) + "...";
        }

        private static string Safe(string value) { return string.IsNullOrWhiteSpace(value) ? "-" : value.Replace("\r", " ").Replace("\n", " "); }
        private static string Escape(string value) { return Safe(value).Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)"); }

        private class Line
        {
            public Line(string text, int size) { Text = text ?? string.Empty; Size = size; }
            public string Text { get; private set; }
            public int Size { get; private set; }
        }
    }
}
