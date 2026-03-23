using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using ACRPortal.Application.port;
using ACRPortal.Domain.DTOs.WebToApp;

namespace ACRPortal.Infrastructure.Adapter
{
    public class DocumentAdapter : IDocumentRepoPort
    {
        private readonly string _conn = ConfigurationManager
            .ConnectionStrings["ACRPortalContext"].ConnectionString;

        // ================================================================== //
        //  ResolveCallerSection                                               //
        //                                                                     //
        //  One query fetches everything needed:                               //
        //    - all six participant IDs                                        //
        //    - current status                                                 //
        //  Then we determine the section and validate the state in C#.       //
        // ================================================================== //
        public bool ResolveCallerSection(Guid acrId, Guid callerId, out string section, out string errorCode)
        {
            const string sql = @"
                SELECT status,
                       cca_user_id,
                       officer_user_id,
                       reporting_user_id,
                       ra2_user_id,
                       reviewing_user_id,
                       accepting_user_id
                FROM   dbo.acr_cycles
                WHERE  acr_id = @acrId";

            section = null;
            errorCode = null;

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }

                    string status = r.IsDBNull(0) ? null : r.GetString(0);
                    Guid ccaId = r.GetGuid(1);
                    Guid officerId = r.GetGuid(2);
                    Guid ra1Id = r.GetGuid(3);
                    Guid? ra2Id = r.IsDBNull(4) ? (Guid?)null : r.GetGuid(4);
                    Guid rvaId = r.GetGuid(5);
                    Guid aaId = r.GetGuid(6);

                    // Determine which section the caller belongs to
                    string resolved = null;
                    if (callerId == ccaId) resolved = "CCA";
                    else if (callerId == officerId) resolved = "OFFICER";
                    else if (callerId == ra1Id) resolved = "RA1";
                    else if (ra2Id.HasValue && callerId == ra2Id.Value) resolved = "RA2";
                    else if (callerId == rvaId) resolved = "RVA";
                    else if (callerId == aaId) resolved = "AA";

                    if (resolved == null) { errorCode = "FORBIDDEN"; return false; }

                    // Validate that the current status allows uploads for this section
                    bool stateOk = IsStateAllowed(resolved, status);
                    if (!stateOk) { errorCode = "INVALID_STATE"; return false; }

                    section = resolved;
                    return true;
                }
            }
        }

        // ================================================================== //
        //  IsParticipant                                                      //
        // ================================================================== //
        public bool IsParticipant(Guid acrId, Guid callerId, out string errorCode)
        {
            const string sql = @"
                SELECT status,
                       cca_user_id,
                       officer_user_id,
                       reporting_user_id,
                       ra2_user_id,
                       reviewing_user_id,
                       accepting_user_id
                FROM   dbo.acr_cycles
                WHERE  acr_id = @acrId";

            errorCode = null;

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { errorCode = "NOT_FOUND"; return false; }

                    Guid ccaId = r.GetGuid(1);
                    Guid officerId = r.GetGuid(2);
                    Guid ra1Id = r.GetGuid(3);
                    Guid? ra2Id = r.IsDBNull(4) ? (Guid?)null : r.GetGuid(4);
                    Guid rvaId = r.GetGuid(5);
                    Guid aaId = r.GetGuid(6);

                    bool isParticipant =
                        callerId == ccaId ||
                        callerId == officerId ||
                        callerId == ra1Id ||
                        (ra2Id.HasValue && callerId == ra2Id.Value) ||
                        callerId == rvaId ||
                        callerId == aaId;

                    if (!isParticipant) { errorCode = "FORBIDDEN"; return false; }
                    return true;
                }
            }
        }

        // ================================================================== //
        //  AddDocument                                                        //
        // ================================================================== //
        public string AddDocument(Guid acrId, string section, string fileUrl, string fileName, string documentType)
        {
            const string sql = @"
                INSERT INTO dbo.acr_documents
                    (document_id, acr_id, section, document_type, file_url, file_name, uploaded_at)
                VALUES
                    (@docId, @acrId, @section, @docType, @fileUrl, @fileName, GETDATE());";

            Guid newId = Guid.NewGuid();

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@docId", SqlDbType.UniqueIdentifier).Value = newId;
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@section", SqlDbType.VarChar).Value = section;
                cmd.Parameters.Add("@docType", SqlDbType.VarChar).Value = (object)documentType ?? DBNull.Value;
                cmd.Parameters.Add("@fileUrl", SqlDbType.NVarChar).Value = fileUrl;
                cmd.Parameters.Add("@fileName", SqlDbType.NVarChar).Value = (object)fileName ?? DBNull.Value;
                con.Open();
                cmd.ExecuteNonQuery();
            }

            return newId.ToString();
        }

        // ================================================================== //
        //  GetDocuments                                                       //
        // ================================================================== //
        public List<AcrDocumentItem> GetDocuments(Guid acrId, string section = null)
        {
            string sql = @"
                SELECT document_id, section, document_type, file_url, file_name, uploaded_at
                FROM   dbo.acr_documents
                WHERE  acr_id = @acrId";

            if (!string.IsNullOrWhiteSpace(section))
                sql += " AND section = @section";

            sql += " ORDER BY uploaded_at ASC";

            var list = new List<AcrDocumentItem>();

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                if (!string.IsNullOrWhiteSpace(section))
                    cmd.Parameters.Add("@section", SqlDbType.VarChar).Value = section;

                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        list.Add(new AcrDocumentItem
                        {
                            DocumentId = r.GetGuid(0).ToString(),
                            Section = r.IsDBNull(1) ? null : r.GetString(1),
                            DocumentType = r.IsDBNull(2) ? null : r.GetString(2),
                            FileUrl = r.IsDBNull(3) ? null : r.GetString(3),
                            FileName = r.IsDBNull(4) ? null : r.GetString(4),
                            UploadedAt = r.IsDBNull(5) ? null : r.GetDateTime(5).ToString("o")
                        });
                    }
                }
            }

            return list;
        }

        // ================================================================== //
        //  DeleteDocument                                                     //
        // ================================================================== //
        public bool DeleteDocument(Guid documentId, Guid acrId, string section)
        {
            const string sql = @"
                DELETE FROM dbo.acr_documents
                WHERE  document_id = @docId
                  AND  acr_id      = @acrId
                  AND  section     = @section";

            using (var con = new SqlConnection(_conn))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.Add("@docId", SqlDbType.UniqueIdentifier).Value = documentId;
                cmd.Parameters.Add("@acrId", SqlDbType.UniqueIdentifier).Value = acrId;
                cmd.Parameters.Add("@section", SqlDbType.VarChar).Value = section;
                con.Open();
                return cmd.ExecuteNonQuery() > 0;
            }
        }

        // ================================================================== //
        //  Private — state validation                                         //
        // ================================================================== //
        private static bool IsStateAllowed(string section, string status)
        {
            if (status == null) return false;

            switch (section)
            {
                case "CCA":
                    // CCA can attach documents at any point except after final decision
                    return status != "APPROVED" && status != "REJECTED";

                case "OFFICER":
                    return status == "PENDING_OFFICER";

                case "RA1":
                case "RA2":
                    return status == "PENDING_REPORTING";

                case "RVA":
                    return status == "PENDING_REVIEWING";

                case "AA":
                    return status == "PENDING_ACCEPTING";

                default:
                    return false;
            }
        }
    }
}