<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background:#faf5f6;font-family:-apple-system,'Segoe UI',Roboto,sans-serif;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#faf5f6;padding:32px 16px;">
        <tr>
            <td align="center">
                <table role="presentation" width="480" cellpadding="0" cellspacing="0" style="max-width:480px;width:100%;background:#ffffff;border-radius:16px;overflow:hidden;">
                    <tr>
                        <td style="background:#285301;padding:28px 32px;text-align:center;">
                            <span style="font-family:Georgia,'Times New Roman',serif;color:#ffffff;font-size:22px;font-weight:600;letter-spacing:0.02em;">Udo</span>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:32px;color:#1a1a1a;font-size:15px;line-height:1.6;">
                            {!! $bodyHtml !!}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:20px 32px;background:#faf5f6;text-align:center;color:#6b7280;font-size:12px;">
                            Udo — your wedding, beautifully managed.<br>
                            &copy; {{ date('Y') }} Udo. If you didn't expect this email, you can safely ignore it.
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
